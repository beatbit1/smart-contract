
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BeatBitMemecoin.sol";

contract ThenaGaugeIntegration is Ownable {
    BeatBitMemecoin public memecoin;

    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
        mapping(address => uint256) votes; // Track votes per user
    }

    mapping(address => uint256) public lockedTokens;
    mapping(address => uint256) public votingPower;
    mapping(uint256 => Proposal) public proposals;
    uint256 public nextProposalId;

    event TokensLocked(address indexed user, uint256 amount);
    event TokensUnlocked(address indexed user, uint256 amount);
    event VoteCast(address indexed voter, uint256 proposalId, uint256 weight);
    event ProposalCreated(uint256 indexed proposalId, string description);
    event ProposalExecuted(uint256 indexed proposalId);

    constructor(BeatBitMemecoin _memecoin) Ownable(msg.sender) {
        memecoin = _memecoin;
    }

    // Lock tokens to gain voting power
    function lockTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        memecoin.transferFrom(msg.sender, address(this), amount);
        lockedTokens[msg.sender] += amount;
        votingPower[msg.sender] += calculateVotingPower(amount);

        emit TokensLocked(msg.sender, amount);
    }

    // Unlock tokens after participation, reducing voting power
    function unlockTokens(uint256 amount) external {
        require(lockedTokens[msg.sender] >= amount, "Insufficient locked tokens");
        lockedTokens[msg.sender] -= amount;
        votingPower[msg.sender] -= calculateVotingPower(amount);
        memecoin.transfer(msg.sender, amount);

        emit TokensUnlocked(msg.sender, amount);
    }

    // Create a new proposal
    function createProposal(string memory description) external onlyOwner {
        Proposal storage newProposal = proposals[nextProposalId];
        newProposal.id = nextProposalId;
        newProposal.description = description;

        emit ProposalCreated(nextProposalId, description);
        nextProposalId++;
    }

    // Cast a vote on a proposal
    function castVote(uint256 proposalId, uint256 weight) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(votingPower[msg.sender] >= weight, "Insufficient voting power");
        require(proposal.votes[msg.sender] == 0, "Already voted on this proposal");

        votingPower[msg.sender] -= weight; // Deduct voting power
        proposal.voteCount += weight; // Add weight to proposal's vote count
        proposal.votes[msg.sender] = weight; // Register the user's vote

        emit VoteCast(msg.sender, proposalId, weight);
    }

    // Execute a proposal once enough votes have been accumulated
    function executeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount > 0, "No votes have been cast");

        proposal.executed = true; // Mark proposal as executed
        emit ProposalExecuted(proposalId);
    }

    // Calculate voting power using a quadratic model
    function calculateVotingPower(uint256 amount) internal pure returns (uint256) {
        return sqrt(amount) * 1e9; 
    }

    // Utility function to calculate square root for quadratic voting
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
