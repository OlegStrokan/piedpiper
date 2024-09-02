// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {GovernorContract} from "../../src/governance/GovernorContract.sol";
import {IVotes} from "lib/openzeppelin-contracts/contracts/governance/utils/IVotes.sol";
import {TimelockController} from "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";
import "lib/forge-std/src/console.sol";

contract DeployGovernorContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address tokenAddress = vm.envAddress(
            "GOVERNANCE_TOKEN_CONTRACT_ADDRESS"
        );
        address timeLockAddress = vm.envAddress("TIME_LOCK_CONTRACT_ADDRESS");

        uint48 votingDelay = 1;
        uint32 votingPeriod = 5;
        uint256 quorumPercentage = 4;

        IVotes token = IVotes(tokenAddress);

        TimelockController timeLock = TimelockController(
            payable(timeLockAddress)
        );

        GovernorContract governorContract = new GovernorContract(
            token,
            timeLock,
            votingDelay,
            votingPeriod,
            quorumPercentage
        );
        console.log("GovernorContract deployed to:", address(governorContract));

        vm.stopBroadcast();
    }
}
