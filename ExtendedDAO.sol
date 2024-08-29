// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ThenaGaugeIntegration.sol";

contract ExtendedDAO is Ownable {
    ThenaGaugeIntegration public gauge;
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
        mapping(address => bool) voters;
    }

    uint256 public nextProposalId;
    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(address indexed voter, uint256 indexed proposalId, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);

    // Corrected constructor to set the initial owner to the deployer
    constructor(ThenaGaugeIntegration _gauge) Ownable(msg.sender) {
        gauge = _gauge;
    }

    function createProposal(string memory description) external onlyOwner {
        proposals[nextProposalId].id = nextProposalId;
        proposals[nextProposalId].description = description;

        emit ProposalCreated(nextProposalId, description);
        nextProposalId++;
    }

    function vote(uint256 proposalId, uint256 weight) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(!proposal.voters[msg.sender], "Already voted");

        gauge.castVote(proposalId, weight);
        proposal.voteCount += weight;
        proposal.voters[msg.sender] = true;

        emit Voted(msg.sender, proposalId, weight);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;

        emit ProposalExecuted(proposalId);
    }
}

