// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "lib/forge-std/src/console.sol";

contract UpgradeProxy is Script {
    address PROXY_ADDRESS = vm.envAddress("BOX_PROXY_CONTRACT_ADDRESS");
    address NEW_IMPLEMENTATION_ADDRESS =
        vm.envAddress("BOX_V2_CONTRACT_ADDRESS");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        (bool success, ) = PROXY_ADDRESS.call(
            abi.encodeWithSignature(
                "upgradeTo(address)",
                NEW_IMPLEMENTATION_ADDRESS
            )
        );
        require(success, "Upgrade failed");

        console.log(
            "Proxy upgraded to new implementation at:",
            NEW_IMPLEMENTATION_ADDRESS
        );

        vm.stopBroadcast();
    }
}
