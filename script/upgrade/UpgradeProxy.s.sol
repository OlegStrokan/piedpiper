// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import "lib/forge-std/src/console.sol";

contract UpgradeProxy is Script {
    address private proxyAddress = vm.envAddress("BOX_PROXY_CONTRACT_ADDRESS");
    address private newImplementationAddress =
        vm.envAddress("BOX_V2_CONTRACT_ADDRESS");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console.log("Attempting to upgrade proxy at address:", proxyAddress);
        console.log("New implementation address:", newImplementationAddress);

        require(proxyAddress != address(0), "Invalid proxy address");
        require(
            newImplementationAddress != address(0),
            "Invalid new implementation address"
        );

        (bool success, bytes memory returnData) = proxyAddress.call(
            abi.encodeWithSignature(
                "upgradeTo(address)",
                newImplementationAddress
            )
        );

        if (!success) {
            string memory revertReason = _decodeRevertReason(returnData);
            console.log("Upgrade failed with reason:", revertReason);
        }
        require(success, "Upgrade failed");

        console.log(
            "Proxy upgraded to new implementation at:",
            newImplementationAddress
        );

        vm.stopBroadcast();
    }

    function _decodeRevertReason(
        bytes memory returnData
    ) internal pure returns (string memory) {
        if (returnData.length < 68) {
            return "No revert reason or invalid revert data";
        }

        bytes memory reasonData = new bytes(returnData.length - 4);
        for (uint256 i = 4; i < returnData.length; i++) {
            reasonData[i - 4] = returnData[i];
        }

        return abi.decode(reasonData, (string));
    }
}
