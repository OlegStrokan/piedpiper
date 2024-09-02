// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract BoxV2 {
    uint256 private value;
    bool isInitialized;

    event ValueChanged(uint256 newValue);

    function initialize(uint256 initValue) external {
        require(!isInitialized, "Already initialized");
        value = initValue;
        isInitialized = true;
    }

    function store(uint256 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }

    function retrieve() public view returns (uint256) {
        return value;
    }

    function calculate() public view returns (uint256) {
        return value * value;
    }
}
