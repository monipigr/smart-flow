// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/FlowToken.sol";
import "../src/SmartFlow.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        // Deploy FLOW
        FlowToken flow = new FlowToken(1_000_000 ether);

        // Deploy SmartFlow
        SmartFlow smartFlow = new SmartFlow(
            address(flow),
            3500 * 1e8, // threshold ETH/USD
            10 ether, // reward per claim
            1 days, // cooldown
            vm.envAddress("PRIMARY_FEED"),
            vm.envAddress("SECONDARY_FEED")
        );

        // Fund SmartFlow
        flow.transfer(address(smartFlow), 1_000_000 ether);

        vm.stopBroadcast();
    }
}
