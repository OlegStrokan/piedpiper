// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Box} from "../src/governance/Box.sol";
import {GovernanceToken} from "../src/governance/token/GovernanceToken.sol";
import {GovernorContract} from "../src/governance/GovernorContract.sol";
import {TimeLock} from "../src/governance/TimeLock.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 minDelay = 3600;
        address;
        address;
        TimeLock timeLock = new TimeLock(minDelay, proposers, executors);
        console.log("TimeLock deployed to:", address(timeLock));

        GovernanceToken token = new GovernanceToken(address(timeLock));
        console.log("Token deployed to:", address(token));

        uint48 votingDelay = 1;
        uint32 votingPeriod = 5;
        uint256 quorumPercentage = 4;
        GovernorContract governorContract = new GovernorContract(
            token,
            timeLock,
            votingDelay,
            votingPeriod,
            quorumPercentage
        );
        console.log("GovernorContract deployed to:", address(governorContract));

        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        timeLock.grantRole(proposerRole, address(governorContract));
        timeLock.grantRole(executorRole, address(0));
        Box boxImplementation = new Box();
        console.log(
            "Box implementation deployed to:",
            address(boxImplementation)
        );

        bytes memory data = abi.encodeWithSignature(
            "initialize(address)",
            msg.sender
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(boxImplementation), data);
        Box box = Box(address(proxy));

        console.log("Box proxy deployed to:", address(box));

        vm.stopBroadcast();
    }
}
