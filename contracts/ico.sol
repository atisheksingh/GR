// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDT is ERC20{
    constructor() ERC20("usdc","usdc"){
        _mint(msg.sender,(10000000000000000000000 * (10 ** 6)));
    }

    function mint(uint256 token) public {
        _mint(msg.sender,(token * (10 ** 6)));
    }
}

contract ICO is Ownable{
    IERC20 public usdc;
    IERC20 public GauRaksha;
    address payable public ownersAddress;
    mapping(uint256 => uint256) public slotId; 
    mapping(uint256 => uint256) public slotPriceInUSDC; 
   


constructor(IERC20 _usdc, IERC20 _GauRaksha, address payable _ownersAddress){
    
        usdc = _usdc;
        GauRaksha = _GauRaksha;
        ownersAddress = _ownersAddress;
        slotId[1] = 40;
        slotId[2] = 25; 
        slotId[3] = 15;
        slotId[4] = 10;
        slotId[5] = 10;
        slotPriceInUSDC[1] = 10 * (10 ** 6);
        slotPriceInUSDC[2] = 10 * (10 ** 6);
        slotPriceInUSDC[3] = 10 * (10 ** 6);
        slotPriceInUSDC[4] = 10 * (10 ** 6);
        slotPriceInUSDC[5] = 10 * (10 ** 6);
      
    }

    receive() external payable {}

    function buyWithUSDC(uint256 _slotId) public {
        require(slotId[_slotId] > 0,"No more slot are available");
        require(_slotId > 0 && _slotId < 6,"Invalid slot");
        if(_slotId == 1){
            require(IERC20(usdc).allowance(msg.sender,address(this)) >= slotPriceInUSDC[1],"ICO1: Need more allowance");
            IERC20(usdc).transferFrom(msg.sender,ownersAddress,10);
            IERC20(GauRaksha).transfer(msg.sender,(50000 * (10 ** 18)));
            
        }
        if(_slotId == 2){ 
            require(IERC20(usdc).allowance(msg.sender,address(this)) >= slotPriceInUSDC[2],"ICO2: Need more allowance");
            IERC20(usdc).transferFrom(msg.sender,ownersAddress,20);
            IERC20(GauRaksha).transfer(msg.sender,(120000 * (10 ** 18)));
       
        }
        if(_slotId == 3){ 
            require(IERC20(usdc).allowance(msg.sender,address(this)) > slotPriceInUSDC[3],"ICO3: Need more allowance");
            IERC20(usdc).transferFrom(msg.sender,ownersAddress,30);
            IERC20(GauRaksha).transfer(msg.sender,(200000 * (10 ** 18)));
       
        }
        if(_slotId == 4){ 
            require(IERC20(usdc).allowance(msg.sender,address(this)) > slotPriceInUSDC[4],"ICO4: Need more allowance");
            IERC20(usdc).transferFrom(msg.sender,ownersAddress,40);
            IERC20(GauRaksha).transfer(msg.sender,(300000 * (10 ** 18)));
       
        }
        if(_slotId == 5){ 
            require(IERC20(usdc).allowance(msg.sender,address(this)) > slotPriceInUSDC[5],"ICO5: Need more allowance");
            IERC20(usdc).transferFrom(msg.sender,ownersAddress,50);
            IERC20(GauRaksha).transfer(msg.sender,(900000 * (10 ** 18)));
       
        }
        slotId[_slotId]--;
    } 
    function setslotPriceInUSDC( uint256[] memory price) public onlyOwner{
        slotPriceInUSDC[1] = price[0];
        slotPriceInUSDC[2] = price[1];
        slotPriceInUSDC[3] = price[2];
        slotPriceInUSDC[4] = price[3];
        slotPriceInUSDC[5] = price[4];
    }
    function withdrawGauRaksha() public onlyOwner {
        uint256 balanceAmount = IERC20(GauRaksha).balanceOf(address(this));
        IERC20(GauRaksha).transfer(msg.sender,balanceAmount);
    }

  
}
