// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    using SafeMathChainlink for uint256;

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lotteryState;

    AggregatorV3Interface internal ethUsdPriceFeed;
    uint256 public usdEntryFee;
    uint256 public randomness;
    address payable[] public players;

    constructor(address _ethUsdPriceFeed) public {
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        usdEntryFee = 50;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        require(msg.value >= getEntranceFee(), "Not enough ETH to enter!");
        require(lotteryState == LOTTERY_STATE.OPEN);
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 precision = 1 * 10**18;
        uint256 price = getLatestEthUsdPrice(); // 8 decimals
        uint256 costToEnter = (precision / price) * (usdEntryFee * 10000000);
        return costToEnter;
    }

    function getLatestEthUsdPrice() public view returns (uint256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint256 startedAt*/ /*uint256 timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = ethUsdPriceFeed.latestRoundData();
        return uint256(price);
    }

    function startLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Lottery already started!");
        lotteryState == LOTTERY_STATE.OPEN;
        randomness = 0;
    }

    // function endLottery() public {}

    // function pickWinner() {}
}
