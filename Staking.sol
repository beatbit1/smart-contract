
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    IERC20 public stakingToken;
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public rewards;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    // Corrected constructor to set the initial owner to the deployer
    constructor(IERC20 _stakingToken) Ownable(msg.sender) {
        stakingToken = _stakingToken;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0");
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakes[msg.sender] += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(stakes[msg.sender] >= amount, "Insufficient balance to unstake");
        stakes[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function distributeRewards(address to, uint256 reward) external onlyOwner {
        rewards[to] += reward;

        emit RewardPaid(to, reward);
    }
}
