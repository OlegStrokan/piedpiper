// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {CustomProxyAdmin} from "../../src/CustomProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "lib/forge-std/src/console.sol";

contract UpgradeBoxProxy is Script {
    address private newImplementationAddress =
        vm.envAddress("BOX_V2_CONTRACT_ADDRESS");
    address private proxyAdminAddress =
        vm.envAddress("BOX_PROXY_ADMIN_CONTRACT_ADDRESS");
    address private proxyAddress = vm.envAddress("BOX_PROXY_CONTRACT_ADDRESS");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        CustomProxyAdmin proxyAdmin = CustomProxyAdmin(proxyAdminAddress);
        ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(
            proxyAddress
        );

        bytes memory data = abi.encodeWithSignature("initialize(uint256)", 20);

        // Upgrade the proxy and call initialize function on the new implementation
        proxyAdmin.upgradeAndCall(proxy, newImplementationAddress, data);
        console.log(
            "Proxy upgraded to new implementation at:",
            newImplementationAddress
        );

        vm.stopBroadcast();
    }
}
