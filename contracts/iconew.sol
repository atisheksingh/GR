// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract USDT is ERC20{
    constructor() ERC20("usdc","usdc"){
        _mint(msg.sender,(10000000000000000000000 * (10 ** 6)));
    }

    function mint(uint256 token) public {
        _mint(msg.sender,(token * (10 ** 6)));
    }
}


contract ICO is Ownable{

    using SafeMath for uint;
    IERC20 public usdc;
    IERC20Metadata public currencyAddress; // USDC address
    IERC20 public GauRaksha;
    address payable public ownersAddress;
    mapping(uint256 => uint256) public slotId; 
    mapping(uint256 => uint256) public slotPriceInUSDC; 



    uint256 Privatesaleslot1 = 25000000;
    uint256 PRslotprice= 10000; //0.01 price in usdc
    uint256 PRslot1bonus = 30;
    bool public PRslot1isActive = false;

    uint256 Privatesaleslot2 = 50000000;
    uint256 PRslot2price =20000; //0.02
    uint256 PRslot2bonus =30;
    bool public PRslot2isActive = false; 

    uint256 Privatesaleslot3 = 50000000;
    uint256 PRslot3price = 30000; //0.03usdc 
    uint256 PRslot3bonus = 30;
    bool public PRslot3isActive = false;

    uint256 GRamountforBonus = 37500000;
    uint256 totalGRtokenforprivatesale = 162500000;

    function ActivateSlot(uint slot_id) public onlyOwner{
        if(slot_id == 1){
            PRslot2isActive = false;
            PRslot3isActive = false;
            PRslot1isActive = true;
        }
        else if(slot_id ==2){
        PRslot3isActive = false;
        PRslot1isActive = false;
        PRslot2isActive= true;

        }else if (slot_id ==3){
           PRslot1isActive = false;
           PRslot2isActive = false;
           PRslot3isActive = true;
        }
        else{
            revert("please select correct slot values");
        }
    }
    modifier slotchecker(uint8 id){
        if(id == 1){
        require(PRslot1isActive == true);
        require(PRslot2isActive == false);
        require(PRslot3isActive == false);
        _;

        }
        else if(id ==2){
        require(PRslot2isActive == true);
        require(PRslot1isActive == false);
        require(PRslot3isActive == false);
        _;
        }
        else if( id ==3){
        require(PRslot3isActive == true);
        require(PRslot1isActive == false);
        require(PRslot2isActive == false);
        _;
        }
        else{
        revert("incorrect slot id"); 
        }
        
    }
    function check () public returns(uint256) {
         return  PRslotprice = PRslotprice.mul(1e6);
    }

    function privateSale(uint256 usdamount , uint8 slot_id) public slotchecker(slot_id)  {
      if(slot_id ==1){
       uint256 tokenamount = usdamount.div(PRslotprice);
       uint256 totalamount = bonusCalculator( slot_id , tokenamount);
       usdc.transferFrom(msg.sender,address(this), usdamount);
       GauRaksha.transferFrom(address(this),msg.sender,totalamount);
      }
      else if(slot_id ==2){
        uint256 tokenamount = usdamount.div(PRslot2price);
       uint256 totalamount = bonusCalculator( slot_id , tokenamount);
       usdc.transferFrom(msg.sender,address(this), usdamount);
       GauRaksha.transferFrom(address(this),msg.sender,totalamount);
      }
     else if(slot_id ==3){
      uint256 tokenamount = usdamount.div(PRslot3price);
       uint256 totalamount = bonusCalculator( slot_id , tokenamount);
       usdc.transferFrom(msg.sender,address(this), usdamount);
       GauRaksha.transferFrom(address(this),msg.sender,totalamount);
      }
      else{
          revert("slot id is inncorrect");
      }
    }
    //  uint TokenPriceUsd = 10 * (10**18);
    //   function buyWithUSDC(uint256 _amount) external {
    //     uint256 usdPrice = TokenPriceUsd * _amount;
    //     uint256 usdcAmount = usdPrice / (10**(18 - currencyDecimals));

    //     currencyAddress.transferFrom(msg.sender, address(this), usdcAmount);

    //     platformToken.mint(msg.sender, _amount);

    //     emit Sale(msg.sender, _amount, kicheeTokenPriceUsd, block.timestamp);
    // }






    function bonusCalculator(uint8 slot , uint amount) internal pure  returns(uint256)  {
        if(slot == 0 ){
            amount = amount.div(100).mul(5);
             return amount;
        }
        else if(slot == 1){
            amount = amount.div(100).mul(5);
             return amount;
        }
        else if (slot ==2 ){
            amount = amount.div(100).mul(5);
            return amount;
        }
        else {
            revert("incorrect slot is choosed"); 
        }
    }


// Slot - 1	25000000	30	32500000	0.000007	USD 0.01
// Slot - 2	50000000	30	65000000	0.000015	USD 0.02
// Slot - 3	50000000	3.00E+01	6.50E+07	0.000023	USD 0.03
}