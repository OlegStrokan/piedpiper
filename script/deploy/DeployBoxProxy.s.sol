// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "lib/openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "lib/forge-std/src/console.sol";

contract DeployBoxProxy is Script {
    address private implementationAddress =
        vm.envAddress("BOX_CONTRACT_ADDRESS");
    address private proxyAdminAddress =
        vm.envAddress("BOX_PROXY_ADMIN_CONTRACT_ADDRESS");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        bytes memory data = abi.encodeWithSignature("initialize(uint256)", 42);

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            implementationAddress,
            proxyAdminAddress,
            data
        );

        console.log("TransparentUpgradeableProxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
}
