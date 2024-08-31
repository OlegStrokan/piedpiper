// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {GovernanceToken} from "./token/GovernanceToken.sol";

contract Governance is Ownable {
    GovernanceToken public govToken;

    struct Proposal {
        uint256 id;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        uint256 endTime;
        bytes data; // Encoded function call and parameters
    }

    Proposal[] public proposals;

    error ProposalCreate__ShortDuration();
    error ProposalCreate__NoData();
    error VoteProposal__VotingPeriodEnded();
    error VoteProposal__NoTokensToVote();
    error ExecuteProposal__VotingNotEnded();
    error ExecuteProposal__AlreadyExecuted();
    error ExecuteProposal__CallFailed();

    event ProposalCreated(uint256 id, string description, uint256 endTime);
    event VoteCast(address voter, uint256 proposalId, bool support);
    event ProposalExecuted(uint256 proposalId);

    constructor(address _govToken) {
        govToken = GovernanceToken(_govToken);
    }

    function createProposal(
        string memory _description,
        uint256 _duration,
        bytes memory _data
    ) external onlyOwner {
        if (_duration <= 0) revert ProposalCreate__ShortDuration();
        if (_data.length == 0) revert ProposalCreate__NoData();

        Proposal memory newProposal = Proposal({
            id: proposals.length,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            endTime: block.timestamp + _duration,
            data: _data
        });

        proposals.push(newProposal);

        emit ProposalCreated(newProposal.id, _description, newProposal.endTime);
    }

    function vote(uint256 _proposalId, bool _support) external {
        Proposal storage proposal = proposals[_proposalId];
        if (block.timestamp > proposal.endTime)
            revert VoteProposal__VotingPeriodEnded();
        uint256 voterBalance = govToken.balanceOf(msg.sender);
        if (voterBalance == 0) revert VoteProposal__NoTokensToVote();

        if (_support) {
            proposal.votesFor += voterBalance;
        } else {
            proposal.votesAgainst += voterBalance;
        }

        emit VoteCast(msg.sender, _proposalId, _support);
    }

    function executeProposal(uint256 _proposalId) external onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        if (block.timestamp < proposal.endTime)
            revert ExecuteProposal__VotingNotEnded();
        if (proposal.executed) revert ExecuteProposal__AlreadyExecuted();
        if (proposal.votesFor <= proposal.votesAgainst) {
            revert ExecuteProposal__CallFailed(); // Proposal did not pass
        }

        (bool success, ) = address(this).call(proposal.data);
        if (!success) revert ExecuteProposal__CallFailed();

        proposal.executed = true;

        emit ProposalExecuted(_proposalId);
    }

    function getProposal(
        uint256 _proposalId
    ) external view returns (Proposal memory) {
        return proposals[_proposalId];
    }
}
