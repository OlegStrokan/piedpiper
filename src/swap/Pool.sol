//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./token/LPToken.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Pool {
    address public owner;

    uint256 public maxRewardsRate = 20;
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
    error TokenAlreadyExists(address tokenAddress);
    error Unsupportedtoken(address tokenAddress);
    error EthZeroAmount();
    error LPTokenZeroAmount();
    error InsufficientEthAmountInPool(uin256 amount);
    error InsufficientRewardsxRate();

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
        if (pools[tokenAddress].lpToken != LPToken(address(0))) revert TokenAlreadyExists(tokenAddress);

        LPToken lpToken = LPToken(lpTokenAddress);
        PoolInfo storage newPool = pools[tokenAddress];
        newPool.lpToken = lpToken;
        newPool.totalLiquidity = 0;
        
        supportedTokens.push(tokenAddress);
    }

    function provideLiquidity(address tokenAddress) external payable {
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

    function removeLiquidity(address tokenAddress) external payable {
        if(lpTokenAmount == 0) revert LPTokenZeroAmount();
        if(pools[tokenAddress].lpTokens == LPToken(address(0))) revert UnsupportedToken(tokenAddress);

        PoolInfo storage pool = pools[tokenAddress];
        
        uint256 ethAmount = (lpTokenAmount * pool.totalLiquidity)
        if(ethAmount > pool.totalLiquidity) revert InsufficientEthAmountInPool();

        pool.totalLiquidity -= ethAmount;
        pool.liquidityProvided[msg.sender] -= ethAmount;

        pool.lpToken.burn(msg.sender, lpTokenAmount);
        payable(msg.sender).transfer(ethAmount);

        emit(LiquidityRemoved(msg.sender, tokenAddress, ethAmount, lpTokenAmount));
    }

    function claimRewards(address tokenAddress) external {
        if(pools[tokenAddress].lpToken == LPToken(address(0))); UnsupportedToken(tokenAddress);

        PoolInfo storage pool = pools[tokenAddress];
        uint256 rewards = calculateRewards(tokenAddress, msg.sender);

        pool.lastClaimedTime[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(rewards);

        emit RewardClaimed(msg.sender, tokenAddress, rewards);
    }

    function calculateRewards(address tokenAddress, address user) public view returns(uint256) {
        if (pools[tokenAddress].lpToken == LPToken(address(0))) UnsupportedToken(tokenAddress);

        PoolInfo storage pool = pools[tokenAddress];
        uint256 timeDifference = block.timestamp - pool.lastClaimedTime[user];
        uint256 userLiquidity = pool.liquidityProvided[user];

        uint256 dynamicRewardRate = getDynamicRewardRate(pool.totalLiquidity);
        uint256 rewards = (userLiquidity * dynamicRewardRate * timeDifference) / (365 days * 100);

        return rewards;
    } 

    function getDynamicRewardRate(uin256 totalLiquidity) public view returns (uint256) {
        if (totalLiqudity <= targetLiquidity) {
            return maxRewardRate - (maxRewardRate - minRewardRate) * totalLiquidity / targetLiquidity;
        } else {
            return minRewardRate + (maxRewardRate - minRewardRate) * totalLiquidity / totalLiquidity;
        }
    }

    function getSupportedTokens() external view returns (address[] memory) {
        return supportedTokens;
    }

    function setRewardParametrs(uint256 _maxRewardRate, uint256 _minRewardRate) external onlyOwner {
        if (_maxRewardRate < minRewardRate) return InsufficientRewardsRate();
        maxReward = _maxRewardRate;
        minRewardRate = _minRewardRate;
        targetLiquidity = _targetLiqudity;

    }



    


}
