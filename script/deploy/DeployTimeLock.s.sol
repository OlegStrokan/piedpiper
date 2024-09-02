// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {TimeLock} from "../../src/governance/TimeLock.sol";
import "lib/forge-std/src/console.sol";

contract DeployTimeLock is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 minDelay = 3600;
        address[] memory proposers;
        address[] memory executors;

        TimeLock timeLock = new TimeLock(minDelay, proposers, executors);
        console.log("TimeLock deployed to:", address(timeLock));

        vm.stopBroadcast();
    }
}
