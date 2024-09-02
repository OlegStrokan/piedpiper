// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract BoxV2 is UUPSUpgradeable, OwnableUpgradeable {
    uint256 private value;

    function initialize(uint256 _value) external initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        value = _value;
    }

    function getValue() external view returns (uint256) {
        return value;
    }

    function calculate() external view returns (uint256) {
        return value * value;
    }

    function setValue(uint256 _value) external onlyOwner {
        value = _value;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
