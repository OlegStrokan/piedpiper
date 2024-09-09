// SPDX-License-Idenfier: MIT
pragma solidity 0.8.24;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StorinToken is ERC20 {
    constructor() ERC20("Storin token", "STRN") {
        pool = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
