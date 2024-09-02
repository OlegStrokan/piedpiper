// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {TimeLock} from "../../src/governance/TimeLock.sol";
import "lib/forge-std/src/console.sol";

contract AssignRoles is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address timeLockAddress = vm.envAddress("TIME_LOCK_CONTRACT_ADDRESS");
        address governorContractAddress = vm.envAddress(
            "GOVERNOUR_CONTRACT_ADDRESS"
        );

        TimeLock timeLock = TimeLock(payable(timeLockAddress));
        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();

        console.log("Granting proposer role to:", governorContractAddress);
        timeLock.grantRole(proposerRole, governorContractAddress);

        console.log("Granting executor role to zero address");
        timeLock.grantRole(executorRole, address(0));

        vm.stopBroadcast();
    }
}
