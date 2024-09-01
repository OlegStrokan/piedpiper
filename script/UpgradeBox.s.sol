// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { BoxV2 } from "../src/governance/BoxV2.sol";

contract UpgradeBox is Script {
    address private proxyAddress = 0xYourBoxProxyAddressHere; // Replace with your Box proxy address

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the BoxV2 contract
        BoxV2 boxV2 = new BoxV2();
        console.log("BoxV2 deployed to:", address(boxV2));

        // Perform the upgrade
        bytes memory data = abi.encodeWithSignature(
            "initialize()"
        );
        ERC1967Proxy(proxyAddress)._upgradeToAndCall(address(boxV2), data);

        vm.stopBroadcast();
    }
}
