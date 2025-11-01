// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPrivateVoting} from "./IPrivateVoting.sol";

// Questions:
//      merkle tree can be a mapping because it's mostly 0 and we just save ones

contract PrivateVoting is IPrivateVoting {
    bool public isSignupActive = true;

    // TODO an sparse merkle tree

    string[] public votes;
    mapping(uint256 => bool) alreadyVotedNullifiers;

    function signup(uint256 commitment) external {
        require(isSignupActive, "signup is not active anymore");
        // TODO Add commitment to my merkle tree
        // A commitment is `MiMC7(secret, 1)`
    }

    function finalize() external {
        isSignupActive = false;
    }

    function vote(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        string memory voteValue,
        uint256 nullifier
    ) external {
        require(!isSignupActive, "signup not finalized yet");
        require(!alreadyVotedNullifiers[nullifier], "you already voted");
        // TODO Contract should prove same user already signed up with a commitment
        // nullifier is `MiMC7(secret, 2)`
        // Relation between MiMC7(secret, 1), MiMC7(secret, 2) prove and verify done with circuits

        alreadyVotedNullifiers[nullifier] = true;
        votes.push(voteValue);
    }
}
