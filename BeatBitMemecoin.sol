// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BeatBitMemecoin is ERC20, Ownable {
    uint256 private constant INITIAL_SUPPLY = 1_000_000_000 * 10**18; // 1 billion tokens

    event TokensMinted(address indexed recipient, uint256 amount);

    constructor() ERC20("BeatBit Memecoin", "BBM") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}

