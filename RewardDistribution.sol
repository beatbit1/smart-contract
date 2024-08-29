// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardDistribution is Ownable {
    mapping(address => uint256) public rewards;

    event RewardDistributed(address indexed to, uint256 amount);

    // Corrected constructor to set the initial owner to the deployer
    constructor() Ownable(msg.sender) {}

    // Function to distribute rewards to a specific address
    function distributeReward(address to, uint256 amount) external onlyOwner {
        rewards[to] += amount;
        emit RewardDistributed(to, amount);
    }

    // Function to allow users to claim their rewards
    function claimReward() external {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to claim");

        rewards[msg.sender] = 0; // Reset the user's reward balance before transferring
        payable(msg.sender).transfer(reward); // Transfer the reward to the user
    }

    // Fallback function to receive ether into the contract
    receive() external payable {}
}

