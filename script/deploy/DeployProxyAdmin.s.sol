// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {CustomProxyAdmin} from "../../src/CustomProxyAdmin.sol";
import "lib/forge-std/src/console.sol";

contract DeployCustomProxyAdmin is Script {
    address private initialOwner = vm.envAddress("OWNER_ADDRESS");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        CustomProxyAdmin proxyAdmin = new CustomProxyAdmin(initialOwner);

        console.log("CustomProxyAdmin deployed to:", address(proxyAdmin));

        vm.stopBroadcast();
    }
}
