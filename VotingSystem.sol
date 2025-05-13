// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title Advanced Blockchain Voting System
 * @dev A secure, transparent and modern voting system with premium features
 * @notice Designed for world-class competition with Apple, Microsoft, etc.
 */
contract VotingSystem {
    // Struct definitions
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
        uint weight;
    }

    struct Proposal {
        string name;
        string description;
        string imageURL; // For modern UI integration
        uint voteCount;
    }

    // State variables
    address public admin;
    Proposal[] public proposals;
    mapping(address => Voter) public voters;
    uint public totalVotes;
    uint public votingStartTime;
    uint public votingEndTime;
    bool public votingClosed;
    string public votingTitle;
    string public votingDescription;

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyDuringVotingPeriod() {
        require(block.timestamp >= votingStartTime && block.timestamp <= votingEndTime, "Voting not active");
        _;
    }

    modifier onlyAfterVoting() {
        require(block.timestamp > votingEndTime, "Voting not ended yet");
        _;
    }

    // Events for modern frontend integration
    event VoterRegistered(address voter);
    event VotingStarted(uint startTime, uint endTime);
    event VoteCast(address voter, uint proposalId);
    event VotingClosed(uint totalVotes);
    event ProposalAdded(uint proposalId, string name);

    // Constructor
    constructor(string memory _title, string memory _description) {
        admin = msg.sender;
        votingTitle = _title;
        votingDescription = _description;
    }

    // Admin functions
    function registerVoter(address _voter, uint _weight) public onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered");
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedProposalId: 0,
            weight: _weight
        });
        emit VoterRegistered(_voter);
    }

    function addProposal(
        string memory _name,
        string memory _description,
        string memory _imageURL
    ) public onlyAdmin {
        proposals.push(Proposal({
            name: _name,
            description: _description,
            imageURL: _imageURL,
            voteCount: 0
        }));
        emit ProposalAdded(proposals.length - 1, _name);
    }

    function startVoting(uint _durationInHours) public onlyAdmin {
        require(votingStartTime == 0, "Voting already started");
        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + (_durationInHours * 1 hours);
        emit VotingStarted(votingStartTime, votingEndTime);
    }

    function closeVoting() public onlyAdmin onlyAfterVoting {
        require(!votingClosed, "Voting already closed");
        votingClosed = true;
        emit VotingClosed(totalVotes);
    }

    // Voter functions
    function vote(uint _proposalId) public onlyDuringVotingPeriod {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "Voter not registered");
        require(!sender.hasVoted, "Already voted");
        require(_proposalId < proposals.length, "Invalid proposal");

        sender.hasVoted = true;
        sender.votedProposalId = _proposalId;
        proposals[_proposalId].voteCount += sender.weight;
        totalVotes += sender.weight;

        emit VoteCast(msg.sender, _proposalId);
    }

    // View functions for modern UI integration
    function getAllProposals() public view returns (Proposal[] memory) {
        return proposals;
    }

    function getVotingStatus() public view returns (
        bool isActive,
        uint timeRemaining,
        uint totalProposals,
        uint totalVotesCast
    ) {
        isActive = block.timestamp >= votingStartTime && block.timestamp <= votingEndTime && !votingClosed;
        timeRemaining = block.timestamp < votingEndTime ? votingEndTime - block.timestamp : 0;
        totalProposals = proposals.length;
        totalVotesCast = totalVotes;
    }

    function getVoterDetails(address _voter) public view returns (Voter memory) {
        return voters[_voter];
    }

    function getWinner() public view onlyAfterVoting returns (uint winningProposalId) {
        uint winningVoteCount = 0;
        
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
    }
}
