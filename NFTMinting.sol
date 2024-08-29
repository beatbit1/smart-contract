// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMinting is ERC721, Ownable {
    uint256 public nextTokenId;

    // Mapping to store URIs for each token
    mapping(uint256 => string) private _tokenURIs;

    event NFTMinted(address indexed creator, uint256 indexed tokenId, string tokenURI);

    constructor() ERC721("BeatBit Music NFT", "BBNFT") Ownable(msg.sender) {}

    // Mint a new NFT to the creator with a specific URI
    function mintNFT(address creator, string memory tokenURI) external onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(creator, tokenId); // Mint the NFT to the creator
        _tokenURIs[tokenId] = tokenURI; // Directly set the URI without checking existence

        emit NFTMinted(creator, tokenId, tokenURI);
        return tokenId;
    }

    // Return the URI of a given token ID
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId]; // Return the URI directly from the mapping
    }
}

