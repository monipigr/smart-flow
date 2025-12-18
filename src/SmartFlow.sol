// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol"; // Contrato Base Upgradeable

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {IAggregatorV3} from "./interfaces/IAggregatorV3.sol";

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

    function setThreshold(uint256 _threshold) external onlyOwner {
        threshold = _threshold;
    }

    function setRewardAmount(uint256 _rewardAmount) external onlyOwner {
        rewardAmount = _rewardAmount;
    }

    function setCooldown(uint256 _cooldown) external onlyOwner {
        cooldown = _cooldown;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // function claimRewardFor(address delegator, address claimer, uint256 nonce, uint256 deadline, bytes calldata signature) external nonReentrant() whenNotPaused() {
    //     (int256 price, uint8 decimals) = getLatestPrice();

    //     require(uint256(price) <= threshold, "ETH price higher than threshold");
    //     require(
    //         lastClaimAt[delegator] == 0 ||
    //             block.timestamp - lastClaimAt[delegator] >= cooldown,
    //         "Must wait 24h"
    //     );
    //     require(block.timestamp <= deadline, "Signature expired");
    //     require(nonce == nonces[delegator], "Invalid nonce")

    //     verifyDelegationSignature(delegator, claimer, nonce, deadline, signature); // @todo implementar funcion privada

    //     nonces[delegator]++;
    //     lastClaimAt[delegator] = block.timestamp;

    //     IERC20(rewardToken).safeTransfer(claimer, rewardAmount);

    //     emit DelegatedRewardClaimed(delegator, claimer, rewardAmount);
    // }
}
