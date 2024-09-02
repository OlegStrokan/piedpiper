// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {GovernanceToken} from "../../src/governance/token/GovernanceToken.sol";
import "lib/forge-std/src/console.sol";

contract DeployGovernanceToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address timeLockAddress = vm.envAddress("TIME_LOCK_CONTRACT_ADDRESS");

        GovernanceToken token = new GovernanceToken(timeLockAddress);
        console.log("GovernanceToken deployed to:", address(token));

        vm.stopBroadcast();
    }
}
