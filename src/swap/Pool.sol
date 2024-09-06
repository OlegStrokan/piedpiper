// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./token/LPToken.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Pool {
    address public owner;

    uint256 public maxRewardsRate = 20;
    uint256 public minRewardRate = 2;
    uint256 public targetLiquidity = 1 ether;

    struct PoolInfo {
        LPToken lpToken;
        uint256 totalLiquidityTokenA;
        uint256 totalLiquidityTokenB;
        mapping(address => uint256) liquidityProvidedTokenA;
        mapping(address => uint256) liquidityProvidedTokenB;
        mapping(address => uint256) lastClaimedTime;
    }

    mapping(address => mapping(address => PoolInfo)) public pools; // tokenA -> tokenB -> PoolInfo
    address[] public supportedTokens;

    error NotTheOwner();
    error TokenAlreadyExists(address tokenA, address tokenB);
    error UnsupportedToken(address tokenA, address tokenB);
    error InsufficientLiquidity();
    error InvalidTokenAmount();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotTheOwner();
        _;
    }

    event LiquidityProvided(
        address indexed user,
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 lpTokens
    );
    event LiquidityRemoved(
        address indexed user,
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 lpTokens
    );
    event RewardsClaimed(
        address indexed user,
        address indexed tokenA,
        address indexed tokenB,
        uint256 rewardAmount
    );

    constructor() {
        owner = msg.sender;
    }

    function addTokenPair(
        address tokenA,
        address tokenB,
        address lpTokenAddress
    ) external onlyOwner {
        if (pools[tokenA][tokenB].lpToken != LPToken(address(0)))
            revert TokenAlreadyExists(tokenA, tokenB);

        LPToken lpToken = LPToken(lpTokenAddress);
        PoolInfo storage newPool = pools[tokenA][tokenB];
        newPool.lpToken = lpToken;
        newPool.totalLiquidityTokenA = 0;
        newPool.totalLiquidityTokenB = 0;

        supportedTokens.push(tokenA);
        supportedTokens.push(tokenB);
    }

    function provideLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    ) external {
        if (amountA == 0 || amountB == 0) revert InvalidTokenAmount();
        if (pools[tokenA][tokenB].lpToken == LPToken(address(0)))
            revert UnsupportedToken(tokenA, tokenB);

        PoolInfo storage pool = pools[tokenA][tokenB];

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        uint256 lpTokensToMint;

        if (pool.totalLiquidityTokenA == 0 && pool.totalLiquidityTokenB == 0) {
            lpTokensToMint = amountA; // Initialize with the first deposit
        } else {
            uint256 totalSupply = pool.lpToken.totalSupply();
            lpTokensToMint =
                (amountA * totalSupply) /
                pool.totalLiquidityTokenA;
        }

        pool.totalLiquidityTokenA += amountA;
        pool.totalLiquidityTokenB += amountB;
        pool.liquidityProvidedTokenA[msg.sender] += amountA;
        pool.liquidityProvidedTokenB[msg.sender] += amountB;
        pool.lastClaimedTime[msg.sender] = block.timestamp;

        pool.lpToken.mint(msg.sender, lpTokensToMint);

        emit LiquidityProvided(
            msg.sender,
            tokenA,
            tokenB,
            amountA,
            amountB,
            lpTokensToMint
        );
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 lpTokenAmount
    ) external {
        if (lpTokenAmount == 0) revert InvalidTokenAmount();
        if (pools[tokenA][tokenB].lpToken == LPToken(address(0)))
            revert UnsupportedToken(tokenA, tokenB);

        PoolInfo storage pool = pools[tokenA][tokenB];

        uint256 amountA = (lpTokenAmount * pool.totalLiquidityTokenA) /
            pool.lpToken.totalSupply();
        uint256 amountB = (lpTokenAmount * pool.totalLiquidityTokenB) /
            pool.lpToken.totalSupply();

        if (
            amountA > pool.totalLiquidityTokenA ||
            amountB > pool.totalLiquidityTokenB
        ) revert InsufficientLiquidity();

        pool.totalLiquidityTokenA -= amountA;
        pool.totalLiquidityTokenB -= amountB;
        pool.liquidityProvidedTokenA[msg.sender] -= amountA;
        pool.liquidityProvidedTokenB[msg.sender] -= amountB;

        pool.lpToken.burn(msg.sender, lpTokenAmount);

        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        emit LiquidityRemoved(
            msg.sender,
            tokenA,
            tokenB,
            amountA,
            amountB,
            lpTokenAmount
        );
    }

    function claimRewards(address tokenA, address tokenB) external {
        if (pools[tokenA][tokenB].lpToken == LPToken(address(0)))
            revert UnsupportedToken(tokenA, tokenB);

        PoolInfo storage pool = pools[tokenA][tokenB];
        uint256 rewards = calculateRewards(tokenA, tokenB, msg.sender);

        pool.lastClaimedTime[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(rewards);

        emit RewardsClaimed(msg.sender, tokenA, tokenB, rewards);
    }

    function calculateRewards(
        address tokenA,
        address tokenB,
        address user
    ) public view returns (uint256) {
        if (pools[tokenA][tokenB].lpToken == LPToken(address(0)))
            revert UnsupportedToken(tokenA, tokenB);

        PoolInfo storage pool = pools[tokenA][tokenB];
        uint256 timeDifference = block.timestamp - pool.lastClaimedTime[user];
        uint256 userLiquidityA = pool.liquidityProvidedTokenA[user];
        uint256 userLiquidityB = pool.liquidityProvidedTokenB[user];

        uint256 dynamicRewardRate = getDynamicRewardRate(
            pool.totalLiquidityTokenA
        );
        uint256 rewards = (userLiquidityA *
            dynamicRewardRate *
            timeDifference) / (365 days * 100);

        return rewards;
    }

    function getDynamicRewardRate(
        uint256 totalLiquidity
    ) public view returns (uint256) {
        if (totalLiquidity <= targetLiquidity) {
            return
                maxRewardRate -
                ((maxRewardRate - minRewardRate) * totalLiquidity) /
                targetLiquidity;
        } else {
            return
                minRewardRate +
                ((maxRewardRate - minRewardRate) * totalLiquidity) /
                totalLiquidity;
        }
    }

    function getSupportedTokens() external view returns (address[] memory) {
        return supportedTokens;
    }

    function setRewardParameters(
        uint256 _maxRewardRate,
        uint256 _minRewardRate
    ) external onlyOwner {
        if (_maxRewardRate < minRewardRate) revert InsufficientRewardsRate();
        maxRewardRate = _maxRewardRate;
        minRewardRate = _minRewardRate;
        targetLiquidity = _targetLiquidity;
    }
}
