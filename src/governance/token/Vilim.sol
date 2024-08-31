// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/extension/ERC20Votes";

contract VimimToken is ERC20Votes {
    uint256 public maxSupply = 1000000;

    constructor() ERC20("VilimToken", "VLM") ERC20Permit("VilimToken") {
        _mint(msg.sender, maxSupply);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address, to, uint256 amount) internal override(ERC20Votes) {
        super._mint(to, amout);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._burn(account, amount);
    }
}
