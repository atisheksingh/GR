const { ethers } = require("ethers");

const getBigNumber = (number) => ethers.BigNumber.from(number);

const getTimeStamp = (date) => Math.floor(date / 1000);

const getTimeStampNow = () => Math.floor(Date.now() / 1000);

const getDate = (timestamp) => new Date(timestamp * 1000).toDateString();

const getSeconds = (days) => 3600*24*days; // Changes days to seconds

const increaseTime = async (seconds) => {
    await network.provider.send("evm_increaseTime", [seconds]);
    await network.provider.send("evm_mine");
};

const setNextBlockTimestamp = async (timestamp) => {
    await network.provider.send("evm_setNextBlockTimestamp", [timestamp])
    await network.provider.send("evm_mine")
};

// Function for converting amount from larger unit (like eth) to smaller unit (like wei)
function convertTo(amount, decimals) {
    return new BigNumber(amount)
        .times('1e' + decimals)
        .integerValue()
        .toString(10);
}

// Function for converting amount from smaller unit (like wei) to larger unit (like ether)
function convertFrom(amount, decimals) {
    return new BigNumber(amount)
        .div('1e' + decimals)
        .toString(10);
}

module.exports = {
    getBigNumber,
    getTimeStamp,
    getTimeStampNow,
    getDate,
    getSeconds,
    increaseTime,
    setNextBlockTimestamp,
    convertTo,
    convertFrom
}