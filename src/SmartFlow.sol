// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {IAggregatorV3} from "./interfaces/IAggregatorV3.sol";

/**
 * @title SmartFlow contract
 * @notice Allows users to claim an ERC20 token when the ETH/USD
 * is below a threshold and the cooldown has ended
 * @dev Uses Chainlink price feeds with fallback mechanism
 */
contract SmartFlow is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    uint256 public constant STALE_FEED_THRESHOLD = 1 hours;

    IERC20 public rewardToken;
    IAggregatorV3 public primaryPriceFeed;
    IAggregatorV3 public secondaryPriceFeed;
    uint256 public rewardAmount;
    uint256 public threshold;
    uint256 public cooldown;

    // Last timestamp user claimed the reward
    mapping(address => uint256) public lastClaimAt;
    mapping(address => uint256) public nonces;

    event RewardClaimed(address indexed user, uint256 amount);
    event DelegatedRewardClaimed(
        address indexed delegator,
        address indexed claimer,
        uint256 amount
    );

    /**
     * @param _rewardToken Address of the ERC20 reward token
     * @param _threshold Price threshold (ETH/USD with feed decimals)
     * @param _rewardAmount Reward amount per claim (token decimals)
     * @param _cooldown Cooldown between claims in seconds
     * @param _primaryPriceFeed Primary Chainlink price feed address
     * @param _secondaryPriceFeed Secondary fallback price feed address
     */
    constructor(
        address _rewardToken,
        uint256 _threshold,
        uint256 _rewardAmount,
        uint256 _cooldown,
        address _primaryPriceFeed,
        address _secondaryPriceFeed
    ) Ownable(msg.sender) {
        require(
            _primaryPriceFeed != address(0),
            "Invalid primary price feed address"
        );
        require(
            _secondaryPriceFeed != address(0),
            "Invalid secondary price feed address"
        );

        rewardToken = IERC20(_rewardToken);
        threshold = _threshold;
        rewardAmount = _rewardAmount;
        cooldown = _cooldown;
        primaryPriceFeed = IAggregatorV3(_primaryPriceFeed);
        secondaryPriceFeed = IAggregatorV3(_secondaryPriceFeed);
    }

    /**
     * @notice Claim reward token if ETH price is below threshold and cooldown has ended
     * @dev Checks price condition, cooldown, and transfers reward
     * @dev Reverts if price is invalid or above threshold
     * @dev Reverts if cooldown period not passed
     */
    function claimMyReward() external nonReentrant whenNotPaused {
        int256 price = getLatestPrice();
        require(price > 0, "Invalid price");
        require(uint256(price) <= threshold, "ETH price higher than threshold");
        require(
            price > 0 && uint256(price) <= threshold,
            "Price condition failed"
        );

        require(
            lastClaimAt[msg.sender] == 0 ||
                block.timestamp - lastClaimAt[msg.sender] >= cooldown,
            "You must wait 24h"
        );

        lastClaimAt[msg.sender] = block.timestamp;

        IERC20(rewardToken).safeTransfer(msg.sender, rewardAmount);

        emit RewardClaimed(msg.sender, rewardAmount);
    }

    /**
     * @notice Get latest ETH/USD price from feeds
     * @dev Tries primary feed first, falls back to secondary if needed
     * @dev Reverts if both feeds fail or return invalid data
     * @return price Latest ETH/USD price (with feed decimals)
     */
    function getLatestPrice() public view returns (int256 price) {
        try primaryPriceFeed.latestRoundData() {
            (, int256 answer, uint256 updatedAt, , ) = primaryPriceFeed
                .latestRoundData();

            require(answer > 0, "Primary feed: price <= 0");
            require(updatedAt > 0, "Primary feed: invalid timestamp");
            require(
                block.timestamp - updatedAt <= STALE_FEED_THRESHOLD,
                "Primary feed: stale"
            );

            price = answer;
        } catch {
            try secondaryPriceFeed.latestRoundData() {
                (, int256 answer, uint256 updatedAt, , ) = secondaryPriceFeed
                    .latestRoundData();

                require(answer > 0, "Secondary feed: price <= 0");
                require(updatedAt > 0, "Secondary feed: invalid timestamp");
                require(
                    block.timestamp - updatedAt <= STALE_FEED_THRESHOLD,
                    "Secondary feed: stale"
                );

                price = answer;
            } catch {
                revert("Both price feeds failed");
            }
        }
    }

    /**
     * @notice Update price threshold
     * @param _threshold New ETH/USD price threshold
     */
    function setThreshold(uint256 _threshold) external onlyOwner {
        threshold = _threshold;
    }

    /**
     * @notice Update reward amount per claim
     * @param _rewardAmount New reward amount
     */
    function setRewardAmount(uint256 _rewardAmount) external onlyOwner {
        rewardAmount = _rewardAmount;
    }

    /**
     * @notice Update cooldown period
     * @param _cooldown New cooldown in seconds
     */
    function setCooldown(uint256 _cooldown) external onlyOwner {
        cooldown = _cooldown;
    }

    /**
     * @notice Pause all reward claims
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause reward claims
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
