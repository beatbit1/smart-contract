// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossChainSwap is Ownable {
    IERC20 public swapToken;
    mapping(address => uint256) public lockedTokens;

    event SwapInitiated(address indexed user, uint256 amount, string targetChain);
    event SwapCompleted(address indexed user, uint256 amount, string targetChain);

    // Constructor that sets the swap token and the owner
    constructor(IERC20 _swapToken) Ownable(msg.sender) {
        swapToken = _swapToken;
    }

    // Function to initiate a cross-chain swap
    function initiateSwap(uint256 amount, string memory targetChain) external {
        require(amount > 0, "Amount must be greater than zero");
        
        // Transfer tokens from user to the contract for locking
        swapToken.transferFrom(msg.sender, address(this), amount);
        lockedTokens[msg.sender] += amount;

        // Emit event to signal off-chain processing
        emit SwapInitiated(msg.sender, amount, targetChain);
    }

    // Function to complete the swap and release tokens on the target chain
    function completeSwap(address user, uint256 amount, string memory targetChain) external onlyOwner {
        require(lockedTokens[user] >= amount, "Insufficient locked tokens");

        // Update locked tokens balance
        lockedTokens[user] -= amount;

        emit SwapCompleted(user, amount, targetChain);
    }

    // Function to withdraw tokens (e.g., in case of refunding)
    function withdrawTokens(address to, uint256 amount) external onlyOwner {
        require(swapToken.balanceOf(address(this)) >= amount, "Insufficient contract balance");

        // Transfer the specified amount to the given address
        swapToken.transfer(to, amount);
    }
}
