// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {SmartFlow} from "../src/SmartFlow.sol";

contract SmartFlowTest is Test {
    address priceFeedEthUsd = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
}

// IERC20 public flowToken;
// uint256 public rewardAmount; // 10 * 1e18
// uint256 public cooldown; // 86400
// uint256 public threshold; // price in eur with feed decimals
// IAggregatorV3 public priceFeed;

// mapping(address => uint256) public lastClaimAt;
// mapping(address => uint256) public nonces; // for delegations

// // EIP-712 domain
// bytes32 public constant DELEGATION_TYPEHASH =
//     keccak256(
//         "DelegatedClaim(address delegator,address claimer,uint256 amount,uint256 nonce,uint256 deadline)"
//     );
// bytes32 private _domainSeparator;

// uint256[50] private __gap;

// function initialize(
//     address _flowToken,
//     address _priceFeed,
//     uint256 _threshold,
//     uint256 _rewardAmount
// ) public initializer {
//     __Ownable_init();
//     __ReentrancyGuard_init();
//     __UUPSUpgradeable_init();

//     flowToken = IERC20Upgradeable(_flowToken);
//     priceFeed = IAggregatorV3(_priceFeed);
//     threshold = _threshold;
//     rewardAmount = _rewardAmount;
//     cooldown = 86400;

//     _domainSeparator = _buildDomainSeparator();
// }

// function _buildDomainSeparator() internal view returns (bytes32) {
//     // EIP-712 Domain with name/version/chainId/verifyingContract
//     return
//         keccak256(
//             abi.encode(
//                 keccak256(
//                     "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
//                 ),
//                 keccak256(bytes("SmartFlow")),
//                 keccak256(bytes("1")),
//                 block.chainid,
//                 address(this)
//             )
//         );
// }

// // fragment
// function getLatestPrice()
//     public
//     view
//     returns (int256 price, uint256 updatedAt)
// {
//     (, int256 answer, , uint256 updated, ) = priceFeed.latestRoundData();
//     return (answer, updated);
// }

// // fragment verifyDelegationSignature
// function _hashDelegation(
//     address delegator,
//     address claimer,
//     uint256 amount,
//     uint256 nonce,
//     uint256 deadline
// ) internal view returns (bytes32) {
//     bytes32 structHash = keccak256(
//         abi.encode(
//             DELEGATION_TYPEHASH,
//             delegator,
//             claimer,
//             amount,
//             nonce,
//             deadline
//         )
//     );
//     return
//         keccak256(
//             abi.encodePacked("\x19\x01", _domainSeparator, structHash)
//         );
// }

// // safe internal price check & freshness
// function _isValidDelegationSignature(
//     address delegator,
//     address claimer,
//     uint256 amount,
//     uint256 nonce,
//     uint256 deadline,
//     bytes calldata signature
// ) internal view returns (bool) {
//     bytes32 digest = _hashDelegation(
//         delegator,
//         claimer,
//         amount,
//         nonce,
//         deadline
//     );
//     address recovered = ECDSAUpgradeable.recover(digest, signature);
//     return recovered == delegator;
// }

// function _priceOk() internal view returns (bool) {
//     (int256 price, uint256 updatedAt) = getLatestPrice();
//     require(price > 0, "invalid price");
//     require(block.timestamp - updatedAt <= MAX_STALENESS, "stale price");
//     // price and threshold both as integers with same decimals handling
//     return uint256(price) <= threshold;
// }

// // fragment
// function claimMyReward() external nonReentrant {
//     require(
//         block.timestamp - lastClaimAt[msg.sender] >= cooldown,
//         "cooldown"
//     );
//     require(_priceOk(), "price too high");
//     require(
//         flowToken.balanceOf(address(this)) >= rewardAmount,
//         "insufficient rewards"
//     );

//     lastClaimAt[msg.sender] = block.timestamp; // effect
//     bool ok = flowToken.transfer(msg.sender, rewardAmount); // interaction
//     require(ok, "transfer failed");

//     emit RewardClaimed(msg.sender, rewardAmount);
// }

// // fragment
// function claimRewardFor(
//     address delegator,
//     address claimer,
//     uint256 amount,
//     uint256 nonce,
//     uint256 deadline,
//     bytes calldata signature
// ) external nonReentrant {
//     require(block.timestamp <= deadline, "signature expired");
//     require(nonce == nonces[delegator], "bad nonce");
//     require(
//         block.timestamp - lastClaimAt[delegator] >= cooldown,
//         "delegator cooldown"
//     );
//     require(_priceOk(), "price too high");
//     require(amount == rewardAmount, "invalid amount"); // simple fixed

//     // verify signature
//     require(
//         _isValidDelegationSignature(
//             delegator,
//             claimer,
//             amount,
//             nonce,
//             deadline,
//             signature
//         ),
//         "invalid signature"
//     );

//     // effect
//     nonces[delegator] += 1;
//     lastClaimAt[delegator] = block.timestamp;

//     // interaction
//     require(
//         flowToken.balanceOf(address(this)) >= amount,
//         "insufficient rewards"
//     );
//     bool ok = flowToken.transfer(claimer, amount);
//     require(ok, "transfer failed");

//     emit DelegatedRewardClaimed(delegator, claimer, amount);
// }

// // admin setters & authorizeUpgrade
// function setThreshold(uint256 _threshold) external onlyOwner {
//     threshold = _threshold;
// }
// function setRewardAmount(uint256 _rewardAmount) external onlyOwner {
//     rewardAmount = _rewardAmount;
// }
// function setCooldown(uint256 _cooldown) external onlyOwner {
//     cooldown = _cooldown;
// }
// function setPriceFeed(address _feed) external onlyOwner {
//     priceFeed = IAggregatorV3(_feed);
// }

// function _authorizeUpgrade(
//     address newImplementation
// ) internal override onlyOwner {}
//}
