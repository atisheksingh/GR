// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "./Vesting.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
abstract contract Crowdsale is Initializable {

  // The token being sold
  IERC20Upgradeable public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  function _Crowdsale_init_unchained(uint256 _rate, address _wallet, IERC20Upgradeable _token) internal onlyInitializing {
    require(_rate > 0, "Rate cant be 0");
    require(_wallet != address(0), "Address cant be zero address");

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // constructor(uint256 _rate, address _wallet, IERC20 _token) {
  //   require(_rate > 0, "Rate cant be 0");
  //   require(_wallet != address(0), "Address cant be zero address");

  //   rate = _rate;
  //   wallet = _wallet;
  //   token = _token;
  // }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  receive () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) internal {
    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    // uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised + weiAmount;

    // _processPurchase(_beneficiary, tokens);
    // emit TokenPurchase(
    //   msg.sender,
    //   _beneficiary,
    //   weiAmount,
    //   tokens
    // );

    _forwardFunds();
  }



  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    virtual
  {
    require(_beneficiary != address(0), "Address cant be zero address");
    require(_weiAmount != 0, "Amount cant be 0");
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.transfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount * rate;
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    payable(wallet).transfer(msg.value);
  }

  /**
   * @dev Change Rate.
   * @param newRate Crowdsale rate
   */
  function _changeRate(uint256 newRate) virtual internal {
    rate = newRate;
  }

  /**
    * @dev Change Token.
    * @param newToken Crowdsale token
    */
  function _changeToken(IERC20Upgradeable newToken) virtual internal {
    token = newToken;
  }

  /**
    * @dev Change Wallet.
    * @param newWallet Crowdsale wallet
    */
  function _changeWallet(address newWallet) virtual internal {
    wallet = newWallet;
  }
}

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
abstract contract TimedCrowdsale is Crowdsale {
  uint256 public openingTime;
  uint256 public closingTime;

  event TimedCrowdsaleOpeningTime(uint256 newOpeningTime);
  event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);
  event TimedNewCrowdsaleExtended(uint256 roundOpeningTime, uint256 roundClosingTime, uint256 roundRate);

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime, "Crowdsale has not started or has been ended");
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  function _TimedCrowdsale_init_unchained(uint256 _openingTime, uint256 _closingTime) internal onlyInitializing {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp, "OpeningTime must be greater than current timestamp");
    require(_closingTime >= _openingTime, "Closing time cant be before opening time");

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  // constructor(uint256 _openingTime, uint256 _closingTime) {
  //   // solium-disable-next-line security/no-block-members
  //   require(_openingTime >= block.timestamp, "OpeningTime must be greater than current timestamp");
  //   require(_closingTime >= _openingTime, "Closing time cant be before opening time");

  //   openingTime = _openingTime;
  //   closingTime = _closingTime;
  // }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend crowdsale.
   * @param newClosingTime Crowdsale closing time
   */
  function _extendTime(uint256 newClosingTime) internal {
    require(newClosingTime >= block.timestamp, "Closing Time must be greater than current timestamp");
    closingTime = newClosingTime;
    emit TimedCrowdsaleExtended(closingTime, newClosingTime);
  }

  /**
   * @dev changing opening Time.
   * @param newOpeningTime Crowdsale opening time 
   */
  function _changeOpeningTime(uint256 newOpeningTime) internal {
    require(newOpeningTime >= block.timestamp, "opening Time must be greater than current timestamp");
    openingTime = newOpeningTime;
    emit TimedCrowdsaleOpeningTime(newOpeningTime);
  }


    /**
   * @dev new round crowdsale.
   * @param roundOpeningTime Crowdsale opening time
   * @param roundClosingTime Crowdsale closing time
   * @param roundRate Crowdsale rate
   */
  function _createNewRound(uint256 roundOpeningTime,uint256 roundClosingTime, uint256 roundRate) internal {
    require(roundOpeningTime >= block.timestamp, "opening Time must be greater than current timestamp");
    require(roundClosingTime >= block.timestamp, "closing Time must be greater than current timestamp");
    openingTime = roundOpeningTime;
    closingTime = roundClosingTime;
    rate = roundRate;
    emit TimedNewCrowdsaleExtended(openingTime, closingTime, rate);
  }
}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
abstract contract FinalizableCrowdsale is TimedCrowdsale, OwnableUpgradeable, PausableUpgradeable {
  bool public isFinalized;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public whenNotPaused{
    require(!isFinalized, "Already Finalized");
    require(hasClosed(), "Crowdsale is not yet closed");

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal virtual {
  }

  function _updateFinalization() internal {
    isFinalized = false;
  }

}

contract CrowdSale is Crowdsale, FinalizableCrowdsale, UUPSUpgradeable{

    mapping(address => uint256) private _balances;
    mapping (address => bool) private _whitelist;
    mapping (address => bool) private _blacklist;

    VestingVault vestingToken;
    uint256 public arcTokenHolderPurchaseTime;
    uint256 public purchaseLimitInWei;
    address public vestingAddress;
    bool public whiteListingStatus;
    uint256 public vestingMonths;
    
    uint256 public round;
    mapping (address => mapping (uint256 => uint256)) private _purchasedAmount;
    bool private firstRound;

    event SetARCTokenHolderClosingTime(uint256 arcTokenHolderPurchaseTime);
    event SetPurchaseLimitInWei(uint256 amount);
    event SetVestingAddress(address vestingAddress);
    event UpdateWhitelistingStatus(bool enable);
    event UpdateVestingMonths(uint256 months);
    event UpdateToFirstRound(uint256 round);
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        uint256 rate,            // rate, in TKNbits
        address payable wallet,  // wallet to send Ether
        IERC20Upgradeable token,     // the token
        VestingVault vesting,    // the token
        uint256 openingTime,     // opening time in unix epoch seconds
        uint256 closingTime,      // closing time in unix epoch seconds
        uint256 arcTokenPurchaseClosingTime, // closing time for ARC Token Holder in unix epoch seconds
        address vestingVaultAddress // vesting Contract Address
    )
      public initializer
    {      
        vestingToken = vesting;
        arcTokenHolderPurchaseTime = arcTokenPurchaseClosingTime;
        purchaseLimitInWei = 1500000000000000000000;
        vestingAddress = vestingVaultAddress;
        whiteListingStatus = true;
        vestingMonths = 9;
        
        _TimedCrowdsale_init_unchained(openingTime, closingTime);
        _Crowdsale_init_unchained(rate, wallet, token);
        __Pausable_init_unchained();
        __Ownable_init_unchained();
        __Context_init_unchained();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /**
     * @dev Addding a account to Whitelisting
     * @param _beneficiary address of the account.
     */
    function addToWhitelist(address _beneficiary) external onlyOwner {
      _whitelist[_beneficiary] = true;
    }

      /**
     * @dev Addding multiple account to Whitelisting
     * @param _beneficiers address of the account.
     */
    function addMultipleAccountToWhitelist(address[] calldata _beneficiers) external onlyOwner {
      for(uint256 i=0; i < _beneficiers.length; i++){
        _whitelist[_beneficiers[i]] = true;
      }
    }

    /**
     * @dev Removing account to Whitelisting
     * @param _beneficiary address of the account.
     */
    function removeFromWhitelist(address _beneficiary) external onlyOwner {
      _whitelist[_beneficiary] = false;
    }

    /**
     * @dev Check weather account to Whitelisted or not.
     * @param _beneficiary address of the account.
     */
    function checkWhitelisted(address _beneficiary) external view returns(bool) {
      return _whitelist[_beneficiary];
    }


    /**
     * @dev Addding a account to Whitelisting
     * @param _beneficiary address of the account.
     */
    function addToBlacklist(address _beneficiary) external onlyOwner {
      _blacklist[_beneficiary] = true;
    }

      /**
     * @dev Addding multiple account to blacklisting
     * @param _beneficiers address of the account.
     */
    function addMultipleAccountToBlacklist(address[] calldata _beneficiers) external onlyOwner {
      for(uint256 i=0; i < _beneficiers.length; i++){
        _blacklist[_beneficiers[i]] = true;
      }
    }

    /**
     * @dev Removing account to blacklisting
     * @param _beneficiary address of the account.
     */
    function removeFromBlacklist(address _beneficiary) external onlyOwner {
      _blacklist[_beneficiary] = false;
    }

    /**
     * @dev Check weather account to blacklisted or not.
     * @param _beneficiary address of the account.
     */
    function checkBlacklisted(address _beneficiary) external view returns(bool) {
      return _blacklist[_beneficiary];
    }


    
    /** 
     * @dev Pause `contract` - pause events.
     *
     * See {ERC20Pausable-_pause}.
     */
    function pauseContract() external virtual onlyOwner {
        _pause();
    }
    
    /**
     * @dev Pause `contract` - pause events.
     *
     * See {ERC20Pausable-_pause}.
     */
    function unPauseContract() external virtual onlyOwner {
        _unpause();
    }

    /**
     * @param _beneficiary Address performing the token purchase
     */
    function buyToken(address _beneficiary) external payable onlyWhileOpen whenNotPaused{
      require(!_blacklist[_beneficiary], "blacklist: Your Account has been blacklisted");
      if((whiteListingStatus) && block.timestamp <= arcTokenHolderPurchaseTime){
        require(_whitelist[_beneficiary], "whitelist: Your Account has not been whitelisted");
      }
      require((_purchasedAmount[_beneficiary][round] + msg.value) <= purchaseLimitInWei, "Maximum purchase Limit exceeded for this round");
      // require(msg.value <= purchaseLimitInWei, "Maximum purchase Limit existed");
      buyTokens(_beneficiary);
      // calculate token amount to be created
      uint256 token_amount = _getTokenAmount(msg.value);

      uint256 tokens = token_amount / 10;
      uint256 balanceAmount = token_amount - tokens;
      // Dev comments - For development _vestingDurationInMonths is set to 10 months and _lockDurationInMonths to 1 month
      vestingToken.addTokenGrant(_beneficiary, balanceAmount, vestingMonths, 1);
      token.transfer(_beneficiary, tokens);
      token.transfer(vestingAddress, balanceAmount);
      _purchasedAmount[_beneficiary][round] += msg.value;
    }

    /**
     * @dev crowd Sale has been completed and balance token has sent back to owner account
     */
    function finalization() virtual internal override{
      uint256 balance = token.balanceOf(address(this));
      if (balance > 0) {
        token.transfer(owner(), balance);
      }
    }

    /**
     * @dev extending the crowd Sale closing time 
     * @param newClosingTime closing time in unix format.
     */
    function extendSale(uint256 newClosingTime) virtual external onlyOwner whenNotPaused{
      _extendTime(newClosingTime);
      _updateFinalization();
    }

    /**
     * @dev create a new round for crowd Sale with new timing 
     * @param roundOpeningTime opening time in unix format.
     * @param roundClosingTime closing time in unix format.
     * @param roundRate rate for round.
     */
    function newCrowdSaleRound(uint256 roundOpeningTime,uint256 roundClosingTime, uint256 roundRate) virtual external onlyOwner whenNotPaused {
      require(isFinalized, "Crowdsale is not yet closed");
      require(hasClosed(), "Crowdsale is not yet closed");
      require(roundRate > 0, "Rate: Amount cannot be 0");
      _createNewRound(roundOpeningTime, roundClosingTime, roundRate);
      _updateFinalization();
      round = round + 1;
    }

    /**
     * @dev change the crowd Sale opening time 
     * @param newOpeningTime opening time in unix format.
     */
    function changeOpeningTime (uint256 newOpeningTime) virtual external onlyOwner whenNotPaused{
      _changeOpeningTime(newOpeningTime);
      _updateFinalization();
    }

    /**
     * @dev Change the rate of the token 
     * @param newRate number of token.
     */
    function changeRate(uint256 newRate) virtual external onlyOwner onlyWhileOpen whenNotPaused{
      require(newRate > 0, "Rate: Amount cannot be 0");
      _changeRate(newRate);
    }

    /**
     * @dev Change the base token address of the token 
     * @param newToken address of the token.
     */
    function changeToken(IERC20Upgradeable newToken) virtual external onlyOwner onlyWhileOpen whenNotPaused{
      require(address(newToken) != address(0), "Token: Address cant be zero address");
      _changeToken(newToken);
    }

    /**
     * @dev Change the rate of the token 
     * @param newWallet number of token.
     */
    function changeWallet(address newWallet) virtual external onlyOwner onlyWhileOpen whenNotPaused{
      require(newWallet != address(0), "Wallet: Address cant be zero address");
      _changeWallet(newWallet);
    }

    /**
     * @dev set the crowd Sale ARC Token Holder closing time 
     * @param arcTokenHolderClosingTime closing time in unix format.
     */
    function setARCTokenHolderClosingTime(uint256 arcTokenHolderClosingTime) external onlyOwner onlyWhileOpen whenNotPaused {
      arcTokenHolderPurchaseTime = arcTokenHolderClosingTime;
      emit SetARCTokenHolderClosingTime(arcTokenHolderPurchaseTime);
    }

    /**
     * @dev set the purchase limit for buy 
     * @param amount  Amount in Wei.
     */
    function setPurchaseLimitInWei(uint256 amount) external onlyOwner onlyWhileOpen whenNotPaused {
      purchaseLimitInWei = amount;
      emit SetPurchaseLimitInWei(purchaseLimitInWei);
    }

    /**
     * @dev set the vesting Address to trnsfer the token 
     * @param _vestingAddress address of the vesting concept
     */
    function setVestingAddress(address _vestingAddress) external onlyOwner onlyWhileOpen whenNotPaused {
      vestingAddress = _vestingAddress;
      emit SetVestingAddress(vestingAddress);
    }

    /**
     * @dev withdraw tokens from the contract 
     * @param to address to receive tokens
     * @param amount amount of token to withdraw
     */
    function withdrawToken(address to, uint256 amount) external onlyOwner onlyWhileOpen whenNotPaused {
      require(to != address(0), "ERC20: transfer to the zero address");
      token.transfer(to, amount);
    } 
    
    /**
     * @dev update the status of the Whitelisting 
     * @param enable update the status of enable/Disable
     */
    function updateWhitelistingStatus(bool enable) external onlyOwner onlyWhileOpen whenNotPaused {
      whiteListingStatus = enable;
      emit UpdateWhitelistingStatus(whiteListingStatus);
    }

    /**
     * @dev Vesting Months to get the values 
     * @param months update the status of enable/Disable
     */
    function updateVestingMonths(uint256 months) external onlyOwner onlyWhileOpen whenNotPaused {
      vestingMonths = months;
      emit UpdateVestingMonths(vestingMonths);
    }

    /**
     * @dev round update for only once
     */
    function updateToFirstRound() external onlyOwner whenNotPaused {
      if(!firstRound){
        round = round + 1;
        firstRound = true;
        emit UpdateToFirstRound(vestingMonths);
      }
    }

    /**
     * @dev check the _beneficiary purchased amount for the current round
     * @param _beneficiary address to check the purchased value for this current round
     */
    function purchasedTokenForCurrentRound(address _beneficiary) external view returns(uint256){
      return _purchasedAmount[_beneficiary][round];
    }
}
