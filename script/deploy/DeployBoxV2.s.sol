// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {BoxV2} from "../../src/governance/BoxV2.sol";
import "lib/forge-std/src/console.sol";

contract DeployBoxV2 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        BoxV2 boxV2 = new BoxV2();
        console.log("BoxV2 deployed to:", address(boxV2));

        uint256 initialValue = 42;
        boxV2.initialize(initialValue);
        console.log("BoxV2 initialized with value:", initialValue);

        vm.stopBroadcast();
    }
}
