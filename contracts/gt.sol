// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract GauRaksha is ERC20Burnable, Ownable {
    using SafeMath for uint256;

    uint256 private constant initialSupply = 1e9 * 10**18; // i billion

    uint256 public constant publicSalePercentage = 4000 ;         //40%
    uint256 public constant marketingPercentage = 1000 ;          //10%
    uint256 public constant stakingPercentage = 2000 ;     //20%
    uint256 public constant TeamPercentage = 1500 ;     //15%
    uint256 public constant liquidityPercentage = 1500 ;          //15%
    uint256 public constant percentageDivider = 10000;  //100%
   
    uint256 public PublicSaleToken;
    uint256 public MarketingToken;
    uint256 public StakingToken;
    uint256 public TeamToken;
    uint256 public LiquidityToken;
    

    constructor(address _user) public ERC20("Gau Raksha", "GAU") {
        PublicSaleToken = (initialSupply.mul(publicSalePercentage)).div(percentageDivider);
        MarketingToken = (initialSupply.mul(marketingPercentage)).div(percentageDivider);
        StakingToken = (initialSupply.mul(stakingPercentage)).div(percentageDivider);
        TeamToken = (initialSupply.mul(TeamPercentage)).div(percentageDivider);
        LiquidityToken = (initialSupply.mul(liquidityPercentage)).div(percentageDivider);
        _mint(_user, initialSupply);
    }

    receive() external payable {
        payable(owner()).transfer(msg.value);
    }

    function fallabck() public payable {
        payable(owner()).transfer(getBalance());
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}