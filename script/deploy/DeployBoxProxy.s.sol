// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "lib/forge-std/src/console.sol";

contract DeployBoxProxy is Script {
    address BOX_IMPLEMENTATION_ADDRESS = vm.envAddress("BOX_CONTRACT_ADDRESS");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        bytes memory data = abi.encodeWithSignature("initialize(uint256)", 42);

        ERC1967Proxy proxy = new ERC1967Proxy(BOX_IMPLEMENTATION_ADDRESS, data);
        console.log("Box proxy deployed to:", address(proxy));

        vm.stopBroadcast();
    }
}
