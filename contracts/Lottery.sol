// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable {
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
    uint256 public fee;
    bytes32 public keyHash;
    address payable[] public players;

    constructor(
        address _ethUsdPriceFeed,
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash
    ) public VRFConsumerBase(_vrfCoordinator, _link) {
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        usdEntryFee = 50;
        fee = 10000000000000000; // 0.1 LINK
        keyHash = _keyHash;
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

    function endLottery(uint256 userProvidedSeed) public onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not opened!");
        lotteryState == LOTTERY_STATE.CALCULATING_WINNER;
        pickWinner(userProvidedSeed);
    }

    function pickWinner(uint256 userProvidedSeed) private returns (bytes32) {
        require(
            lotteryState == LOTTERY_STATE.CALCULATING_WINNER,
            "Lottery not closed for new entries!"
        );
        bytes32 requestId = requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        require(randomness > 0, "Random number not found!");
        uint256 index = randomness % players.length;
        players[index].transfer(address(this).balance);
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
        randomness = randomness;
    }
}
