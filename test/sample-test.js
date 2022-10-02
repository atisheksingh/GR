const { expect } = require("chai");
const { ethers } = require("hardhat");
const { parseUnits } = require("@ethersproject/units");
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace");
const {
  getTimeStamp,
  getTimeStampNow,
  getDate,
  getSeconds,
  increaseTime,
  setNextBlockTimestamp,
  convertTo,
  convertFrom
} = require("./helpers");
//const { parseUnits } = require("@ethersproject/units");

var  PublicSaleTokenvalue;
var  MarketingTokenvalue ;
var StakingTokenvalue ;
var  TeamTokenValue ;
var LiquidityTokenvalue;

describe("setup", ()=> {
  // before(async ()=> {
    it("should be equal to given total supply",async function() {
    accounts = await ethers.getSigners();
    [owner,u1,u2,u3,u4]= accounts;
    const tokeninstance = await ethers.getContractFactory('GauRaksha')

    token = await tokeninstance.deploy(owner.address);
    var t1 = await token.totalSupply();
   expect(t1).to.equal(parseUnits('1000000000', 18))
   console.log("1 billion ",t1.toString());

    for (let i = 1; i < 10; i++) {
      await token.transfer(accounts[i].address, 1000);
      console.log(`${accounts[i].address} received ${(await token.balanceOf(accounts[i].address)).toString()} tokens`);
  }
 
  })
  it("should display public sale ",async function(){
    PublicSaleTokenvalue = await token.PublicSaleToken();
    console.log("public sale value", PublicSaleTokenvalue.toString() );
  })
  it("should display MarketingToken ",async function(){
    MarketingTokenvalue = await token.MarketingToken();
    console.log("MarketingToken value", MarketingTokenvalue.toString() );
  })
  it("should display StakingToken ",async function(){
    StakingTokenvalue = await token.StakingToken();
    console.log("StakingToken value", StakingTokenvalue.toString() );
  })
  it("should display TeamToken ",async function(){
    TeamTokenValue = await token.TeamToken();
    console.log("TeamToken value", TeamTokenValue.toString() );
  })
  it("should display public sale ",async function(){
    LiquidityTokenvalue = await token.LiquidityToken();
    console.log("LiquidityToken value", LiquidityTokenvalue.toString() );
  })

  it('should give value equal to 1 billion ', async function(){
    var total = 
  parseInt(PublicSaleTokenvalue)+
  parseInt(MarketingTokenvalue) +
  parseInt(StakingTokenvalue) +
  parseInt(TeamTokenValue) +
  parseInt(LiquidityTokenvalue);

  expect(total).to.equal(parseUnits('1000000000', 18))
  console.log("1 billion ",total.toString());
  })
  


});