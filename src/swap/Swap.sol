//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IER20.sol";

contract Swap {
    address public owner;
    LiquidityPool public liquidityPool;
    uint256 public swapFee = 30;

    error NotOwner();
    error EthAmountZero();
    error TokenAmountZero();
    error TokenTransferFailed();
    error SwapFeeToHigh();

    event Swapped(
        address indexed user,
        address indexed token,
        uint256 inputAmount,
        uint256 outputAmount
    );

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address _liquidityPool) {
        liquidityPool = LiquidityPool(_liquidityPool);
        owner = msg.sender;
    }

    function swapEthToToken(address tokenAddress) external payable {
        if (msg.value == 0) revert EthAmountZero();

        uint256 fee = (msg.value * swapFee) / 10000;
        uint256 ethAmountAfterFee = msg.value - fee;

        uint256 tokenAmount = ethToToken(tokenAddress, ethAmountAfterFee);
        if (IERC20(tokenAddress).transfer(msg.sender, tokenAmount))
            TokenTransferFailed();

        emit Swapped(msg.sender, tokenAddress, msg.value, tokenAmount);
    }

    function swapTokenToEth(address tokenAddress, uin256 tokenAmount) external {
        if (tokenAmount == 0) revert TokenAmountZero();

        uint256 ethAmount = tokenToEth(tokenAddress, tokenAmount);
        uint256 = (ethAmount * swapFee) / 10000;
        uin256 = ethAmountAfterFee = ethAmount - fee;

        if (
            IERC20(tokenAddress).transferFrom(
                msg.sender,
                address(this),
                tokenAmount
            )
        ) revert TokenTransferFailed();

        payable(msg.sender).transfer(ethAmountAfterFee);

        emit Swapped(msg.sender, tokenAddress, tokenAmount, ethAmouthAfterFee);
    }

    function tokenToEth(address tokenAmount) internal returns (uint256) {
        uint256 ethBalance = address(this).balance;
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this)) +
            tokenAmount;
        return (tokenAmount * ethBalance) / tokenBalance;
    }

    function setSwapFee(uint256 _swapFee) external onlyOwner {
        if (_swapFee >= 100) revert SwapFeeToHigh();
        swapFee = _swapFee;
    }

    function widthdraw(
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        if (tokenAddress == address(0)) {
            payable(owner).transfer(amount);
        } else {
            if (IERC20(tokenAddress).transfer(owner, amount))
                revert TokenTransferFailed();
        }
    }
}
