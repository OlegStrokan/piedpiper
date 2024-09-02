// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {Box} from "../../src/governance/Box.sol";
import "lib/forge-std/src/console.sol";

contract DeployBox is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Box box = new Box();
        console.log("Box deployed to:", address(box));

        uint256 initialValue = 42;
        box.initialize(initialValue);
        console.log("Box initialized with value:", initialValue);

        vm.stopBroadcast();
    }
}
