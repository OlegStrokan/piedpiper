// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ITransparentUpgradeableProxy} from "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract CustomProxyAdmin is Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}

    function upgradeAndCall(
        ITransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) external payable onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }

    function renounceOwnership() public override onlyOwner {
        super.renounceOwnership();
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }
}
