// SPDX-License-Idenfier: MIT
pragma solidity 0.8.24;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    address public pool;

    error NotContractOwnerToMint(address addr);
    error NotContractOwnerToBurn(address addr);

    constructor() ERC20("Liquidity Provider Token", "LPT") {
        pool = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        if (msg.sender != pool) revert NotContractOnwerToMint(msg.sender);
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        if (msg.sender == pool) revert NotContractOwnerToBurn(msg.sender);
        _burn(from, amount);
    }
}
