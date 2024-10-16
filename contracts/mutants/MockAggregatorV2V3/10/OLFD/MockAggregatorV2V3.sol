pragma solidity ^0.5.16;

interface AggregatorV2V3Interface {
    

    

    

    

    

    
}

contract MockAggregatorV2V3 is AggregatorV2V3Interface {
    uint80 public roundId = 0;
    uint8 public keyDecimals = 0;

    struct Entry {
        uint80 roundId;
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    mapping(uint => Entry) public entries;

    bool public allRoundDataShouldRevert;
    bool public latestRoundDataShouldRevert;

    constructor() public {}

    // Mock setup function
    function setLatestAnswer(int256 answer, uint256 timestamp) external {
        roundId++;
        entries[roundId] = Entry({
            roundId: roundId,
            answer: answer,
            startedAt: timestamp,
            updatedAt: timestamp,
            answeredInRound: roundId
        });
    }

    function setLatestAnswerWithRound(
        int256 answer,
        uint256 timestamp,
        uint80 _roundId
    ) external {
        roundId = _roundId;
        entries[roundId] = Entry({
            roundId: roundId,
            answer: answer,
            startedAt: timestamp,
            updatedAt: timestamp,
            answeredInRound: roundId
        });
    }

    function setAllRoundDataShouldRevert(bool _shouldRevert) external {
        allRoundDataShouldRevert = _shouldRevert;
    }

    function setLatestRoundDataShouldRevert(bool _shouldRevert) external {
        latestRoundDataShouldRevert = _shouldRevert;
    }

    function setDecimals(uint8 _decimals) external {
        keyDecimals = _decimals;
    }

    

    

    

    

    function getTimestamp(uint256 _roundId) external view returns (uint256) {
        Entry memory entry = entries[_roundId];
        return entry.updatedAt;
    }

    function getRoundData(uint80 _roundId)
        public
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        if (allRoundDataShouldRevert) {
            revert("getRoundData reverted");
        }

        Entry memory entry = entries[_roundId];
        // Emulate a Chainlink aggregator
        require(entry.updatedAt > 0, "No data present");
        return (entry.roundId, entry.answer, entry.startedAt, entry.updatedAt, entry.answeredInRound);
    }
}
