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

var PublicSaleTokenvalue;
var MarketingTokenvalue;
var StakingTokenvalue;
var TeamTokenValue;
var LiquidityTokenvalue;

describe("setup", () => {
  // before(async ()=> {
  it("should be equal to given total supply", async function () {
    accounts = await ethers.getSigners();
    [owner,mod, u1, u2, u3, u4] = accounts;
    const tokeninstance = await ethers.getContractFactory('GauRaksha')
    const usdcinstance = await ethers.getContractFactory("USDT")
    const icoinstance = await ethers.getContractFactory("ICO")
    token = await tokeninstance.deploy(owner.address);
    usdc = await usdcinstance.deploy();
    var t1 = await token.totalSupply();
    var t2 = await usdc.totalSupply();
    ico = await icoinstance.deploy(usdc.address, token.address, mod.address)


    expect(t1).to.equal(parseUnits('1000000000', 18))
    console.log("1 billion ", t1.toString());
    console.log("total supply of the usdc ", t2.toString());
    console.log(" ico is depolyed to ", ico.address);

    
    for (let i = 2; i < 5; i++) {
      await usdc.transfer(accounts[i].address, 1000);
      //provding asset to buy in ico 
      console.log(`${accounts[i].address} received ${(await usdc.balanceOf(accounts[i].address)).toString()} usdc tokens`);
    }
    
    for (let i = 2; i < 5; i++) {
      //await toke.transfer(accounts[i].address, 1000);
      //checking gr Token before ico 
      console.log(`${accounts[i].address} received ${(await token.balanceOf(accounts[i].address)).toString()} GR tokens`);
    }

  })
  it("should display public sale ", async function () {
    PublicSaleTokenvalue = await token.PublicSaleToken();
    console.log("public sale value", PublicSaleTokenvalue.toString());
    //giving ico contract to allowance to use pre_sale token amount to transfer in ico sale 
    await token.transfer(ico.address,PublicSaleTokenvalue);
    icobalance = await token.balanceOf(ico.address);
    console.log('pre_minting token transfer', icobalance.toString())
  })
  it("should display MarketingToken ", async function () {
    MarketingTokenvalue = await token.MarketingToken();
    console.log("MarketingToken value", MarketingTokenvalue.toString());
  })
  it("should display StakingToken ", async function () {
    StakingTokenvalue = await token.StakingToken();
    console.log("StakingToken value", StakingTokenvalue.toString());
  })
  it("should display TeamToken ", async function () {
    TeamTokenValue = await token.TeamToken();
    console.log("TeamToken value", TeamTokenValue.toString());
  })
  it("should display public sale ", async function () {
    LiquidityTokenvalue = await token.LiquidityToken();
    console.log("LiquidityToken value", LiquidityTokenvalue.toString());
  })
  it("should buy from usdc",async function (){
    //getting allowance from user for usdc to ico-contract to transfer to owner account 
    await usdc.connect(u1).approve(ico.address,"1000000000000");
    await ico.connect(u1).buyWithUSDC("1");
    await usdc.connect(u2).approve(ico.address,"1000000000000");
    await ico.connect(u2).buyWithUSDC("1");
    await usdc.connect(u3).approve(ico.address,"1000000000000");
    await ico.connect(u3).buyWithUSDC("1");
    for (let i = 2; i < 5; i++) {
      console.log(`${accounts[i].address} received ${(await token.balanceOf(accounts[i].address)).toString()} GR tokens`);
    }
  })
  it('should decrease the balance of ico contract',async function (){
    icobalance = await token.balanceOf(ico.address);
    console.log('ico contract balance after transfer', icobalance.toString())
  })
  it('should update value usdc in mods address', async function (){
    modbal = await usdc.balanceOf(mod.address);
    expect(modbal).to.equal('30')
    console.log('balance of the admin ',modbal.toString());
  })
});