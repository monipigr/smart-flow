// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract MockAggregator {
    int256 private price;
    uint256 private updatedAt;
    bool private shouldFail;

    constructor(int256 _price) {
        price = _price;
        updatedAt = block.timestamp;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt_,
            uint80 answeredInRound
        )
    {
        if (shouldFail) {
            revert("Mock feed failure");
        }

        return (1, price, updatedAt, updatedAt, 1);
    }

    function setPrice(int256 _price) external {
        price = _price;
        updatedAt = block.timestamp;
    }

    function setTimestamp(uint256 _timestamp) external {
        updatedAt = _timestamp;
    }

    function setShouldFail(bool _shouldFail) public {
        shouldFail = _shouldFail;
    }
}
