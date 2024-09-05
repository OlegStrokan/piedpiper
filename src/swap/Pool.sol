//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./token/LPToken.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Pool {
    address public owner;

    uint256 public maxRewardsRate = 10;
    uint256 public minRewardRate = 2;
    uint256 public targetLiquidity = 1 ether;

    struct PoolInfo {
        LPToken lptoken;
        uint256 totalLiquidity;
        mapping(address => uint256) liquidityProvided;
        mapping(address => uint256 lastClaimedTime;
    }

    mapping(address => PoolInfo) public pools;
    address[] public supportedTokens;


    error NotTheOwner()
    error Unsupportedtoken(address tokenAddress);
    error EthZeroAmount();

    modifier onlyOnwer() {
        if(msg.sender != owner) revert NotTheOwner();
        _;
    }

    event LiquidityProvided(address indexed user, address indexed token, uint256 ethAmount, uint256 lpTokens);
    event LiquidityRemoved(address indexed user, address indexed token, uint256 ethAmount, uin256 lpTokens);
    event RewardsClaimed(address indexed user, address indexed token, uint256 rewardAmount);

    constructor() {
        owner = msg.sender;
    }

    function addToken(address tokenAddress, address lpTokenAddress) external onlyOwner {
        if (msg.value == 0) revert EthZeroAmount();
        if (pools[tokenAddress].lpToken == LPToken(address(0))) revert UnsupportedToken(tokenAddress);
        
        PoolInfo storage pool - pools[tokenAddress];

        uint256 lpTokensToMint = (pool.totalLiquidity == 0)
        ? msg.value
        : (msg.value * pool.lpToken.totalSupply()) / pool.totalLiquidity;

        pool.totalLiquidity += msg.value;
        pool.liquidityProvider[msg.sender] += msg.value;
        pool.lastClaimedTime[msg.sender] = block.timestamp;

        pool.lpToken.mint(msg.sender, lpTokensToMint);

        emit LiquidityProvided(msg.sender, tokenAddress, msg.value, lpTokensToMint);
    };

    

}
