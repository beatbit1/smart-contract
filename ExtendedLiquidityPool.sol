
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BeatBitMemecoin.sol";

contract ExtendedLiquidityPool is Ownable {
    IERC20 public liquidityToken;
    BeatBitMemecoin public memecoin;
    mapping(address => uint256) public liquidityStakes;
    mapping(address => uint256) public poolRewards;

    event LiquidityAdded(address indexed user, uint256 amount);
    event LiquidityRemoved(address indexed user, uint256 amount);
    event RewardsDistributed(address indexed user, uint256 reward);

    // Corrected constructor passing msg.sender as the initial owner
    constructor(IERC20 _liquidityToken, BeatBitMemecoin _memecoin) Ownable(msg.sender) {
        liquidityToken = _liquidityToken;
        memecoin = _memecoin;
    }

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "Cannot add 0 liquidity");
        liquidityToken.transferFrom(msg.sender, address(this), amount);
        liquidityStakes[msg.sender] += amount;

        // Optionally distribute memecoin rewards for adding liquidity
        memecoin.mint(msg.sender, amount / 10); // Mint 10% reward in memecoin

        emit LiquidityAdded(msg.sender, amount);
    }

    function removeLiquidity(uint256 amount) external {
        require(liquidityStakes[msg.sender] >= amount, "Insufficient liquidity to remove");
        liquidityStakes[msg.sender] -= amount;
        liquidityToken.transfer(msg.sender, amount);

        emit LiquidityRemoved(msg.sender, amount);
    }

    function distributePoolRewards(address to, uint256 reward) external onlyOwner {
        poolRewards[to] += reward;

        emit RewardsDistributed(to, reward);
    }
}
