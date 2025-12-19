// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/SmartFlow.sol";

import {MockAggregator} from "../src/MockAggregator.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract SmartFlowTest is Test {
    SmartFlow public smartFlow;

    // Mock contracts
    IERC20 public rewardToken;
    MockAggregator public primaryPriceFeed;
    MockAggregator public secondaryPriceFeed;

    // Test addresses
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    // Constants
    uint256 public constant THRESHOLD = 3500 * 1e8; // $3500 with 8 decimals
    uint256 public constant REWARD_AMOUNT = 10 * 1e18; // 10 tokens
    uint256 public constant COOLDOWN = 24 hours;

    function setUp() public {
        vm.startPrank(owner);

        // Deploy mock contracts
        rewardToken = IERC20(address(new MockERC20()));

        primaryPriceFeed = new MockAggregator(2800);
        secondaryPriceFeed = new MockAggregator(2850);

        // Deploy SmartFlow contract
        smartFlow = new SmartFlow(
            address(rewardToken),
            THRESHOLD,
            REWARD_AMOUNT,
            COOLDOWN,
            address(primaryPriceFeed),
            address(secondaryPriceFeed)
        );

        vm.stopPrank();

        // Fund the contract with reward tokens
        MockERC20(address(rewardToken)).mint(
            address(smartFlow),
            1_000_000 ether
        );

        // Give users some ETH for gas
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function test_claimMyReward() public {
        uint256 initialBalance = rewardToken.balanceOf(user1);
        uint256 contractBalance = rewardToken.balanceOf(address(smartFlow));

        vm.startPrank(user1);
        smartFlow.claimMyReward();
        vm.stopPrank();

        uint256 finalBalance = rewardToken.balanceOf(user1);
        uint256 finalContractBalance = rewardToken.balanceOf(
            address(smartFlow)
        );

        assertEq(finalBalance - initialBalance, REWARD_AMOUNT);
        assertEq(contractBalance - finalContractBalance, REWARD_AMOUNT);
        assertEq(smartFlow.lastClaimAt(user1), block.timestamp);
    }

    function test_claimMyReward_revertIfPriceAboveThreshold() public {
        primaryPriceFeed.setPrice(3800 * 1e8);
        vm.startPrank(user1);
        vm.expectRevert("ETH price higher than threshold");
        smartFlow.claimMyReward();
        vm.stopPrank();
    }

    function test_claimMyReward_revertIfPriceZero() public {
        MockAggregator(address(primaryPriceFeed)).setPrice(0);

        vm.startPrank(user1);
        vm.expectRevert("Primary feed: price <= 0");
        smartFlow.claimMyReward();
        vm.stopPrank();
    }

    function test_claimMyReward_revertIfCooldownNotPassed() public {
        vm.startPrank(user1);
        smartFlow.claimMyReward();
        vm.stopPrank();

        // Try to claim again only 1 hour later
        vm.warp(block.timestamp + 1 hours);
        vm.startPrank(user1);
        vm.expectRevert("You must wait 24h");
        smartFlow.claimMyReward();
        vm.stopPrank();
    }

    function test_claimMyReward_cooldownPassed() public {
        vm.startPrank(user1);
        smartFlow.claimMyReward();
        vm.stopPrank();

        // Skip time to pass cooldown
        vm.warp(block.timestamp + COOLDOWN + 1);
        primaryPriceFeed.setPrice(2500 * 1e8);

        // Claim again
        uint256 initialBalance = rewardToken.balanceOf(user1);

        vm.startPrank(user1);
        smartFlow.claimMyReward();
        vm.stopPrank();

        uint256 finalBalance = rewardToken.balanceOf(user1);
        assertEq(finalBalance - initialBalance, REWARD_AMOUNT);
    }

    function test_claimMyReward_primaryFeedFails_usesSecondary() public {
        // Make primary feed fail
        MockAggregator(address(primaryPriceFeed)).setShouldFail(true);

        vm.startPrank(user1);
        smartFlow.claimMyReward();
        vm.stopPrank();

        assertEq(smartFlow.lastClaimAt(user1), block.timestamp);
    }

    function test_claimMyReward_revertIFbothFeedsFail() public {
        // Make both feeds fail
        MockAggregator(address(primaryPriceFeed)).setShouldFail(true);
        MockAggregator(address(secondaryPriceFeed)).setShouldFail(true);

        vm.startPrank(user1);
        vm.expectRevert("Both price feeds failed");
        smartFlow.claimMyReward();
        vm.stopPrank();
    }

    function test_claimMyReward_stalePrimaryFeed() public {
        vm.warp(10 hours);
        MockAggregator(address(primaryPriceFeed)).setTimestamp(
            block.timestamp - 2 hours
        );

        MockAggregator(address(primaryPriceFeed)).setPrice(2500 * 1e8);
        MockAggregator(address(secondaryPriceFeed)).setPrice(2400 * 1e8);

        vm.startPrank(user1);
        smartFlow.claimMyReward();
        vm.stopPrank();

        assertEq(smartFlow.lastClaimAt(user1), block.timestamp);
    }

    function test_claimMyReward_revertIfPaused() public {
        vm.startPrank(owner);
        smartFlow.pause();
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert();
        smartFlow.claimMyReward();
        vm.stopPrank();
    }

    // Test owner functions
    function test_setThreshold() public {
        uint256 newThreshold = 4000 * 1e8;

        vm.startPrank(owner);
        smartFlow.setThreshold(newThreshold);
        vm.stopPrank();

        assertEq(smartFlow.threshold(), newThreshold);
    }

    function test_setThreshold_RevertIfNotOwner() public {
        vm.startPrank(user1);
        vm.expectRevert();
        smartFlow.setThreshold(4000 * 1e8);
        vm.stopPrank();
    }

    function test_setRewardAmount() public {
        uint256 newRewardAmount = 200 * 1e18;

        vm.startPrank(owner);
        smartFlow.setRewardAmount(newRewardAmount);
        vm.stopPrank();

        assertEq(smartFlow.rewardAmount(), newRewardAmount);
    }

    function test_setRewardAmount_revertIfNoOwner() public {
        uint256 newRewardAmount = 200 * 1e18;

        vm.startPrank(user1);
        vm.expectRevert();
        smartFlow.setRewardAmount(newRewardAmount);
        vm.stopPrank();
    }

    function test_setCooldown() public {
        uint256 newCooldown = 48 hours;

        vm.startPrank(owner);
        smartFlow.setCooldown(newCooldown);
        vm.stopPrank();

        assertEq(smartFlow.cooldown(), newCooldown);
    }

    function test_setCooldown_revertIfNotOwner() public {
        uint256 newCooldown = 48 hours;

        vm.startPrank(user1);
        vm.expectRevert();
        smartFlow.setCooldown(newCooldown);
        vm.stopPrank();
    }

    function test_pause_unpause() public {
        // Test pause
        vm.startPrank(owner);
        smartFlow.pause();
        vm.stopPrank();

        assertTrue(smartFlow.paused());

        // Test unpause
        vm.startPrank(owner);
        smartFlow.unpause();
        vm.stopPrank();

        assertFalse(smartFlow.paused());
    }

    function test_pause_revertIfNotOwner() public {
        vm.startPrank(user1);
        vm.expectRevert();
        smartFlow.pause();
        vm.stopPrank();
    }

    // Test getLatestPrice function
    function test_getLatestPrice_primaryFeed() public {
        int256 price = smartFlow.getLatestPrice();
        assertEq(uint256(price), 2800);
    }

    function test_getLatestPrice_secondaryFeed() public {
        // Make primary feed fail
        MockAggregator(address(primaryPriceFeed)).setShouldFail(true);

        int256 price = smartFlow.getLatestPrice();
        assertEq(uint256(price), 2850);
    }

    function test_multipleUsers_claim() public {
        // User 1 claims
        vm.startPrank(user1);
        smartFlow.claimMyReward();
        vm.stopPrank();

        // User 2 claims
        vm.startPrank(user2);
        smartFlow.claimMyReward();
        vm.stopPrank();

        assertEq(smartFlow.lastClaimAt(user1), block.timestamp);
        assertEq(smartFlow.lastClaimAt(user2), block.timestamp);
    }

    function test_claim_afterThresholdChange() public {
        // Set price slightly above original threshold
        MockAggregator(address(primaryPriceFeed)).setPrice(3500 * 1e8);

        // Increase threshold
        vm.startPrank(owner);
        smartFlow.setThreshold(4000 * 1e8);
        vm.stopPrank();

        // Now claim should succeed
        vm.startPrank(user1);
        smartFlow.claimMyReward();
        vm.stopPrank();
    }
}

// Mock contract
contract MockERC20 is IERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public totalSupply;
    uint8 public decimals = 18;

    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }
}
