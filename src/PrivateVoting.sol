// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPrivateVoting} from "./IPrivateVoting.sol";
import {IPoseidon} from "./IPoseidon.sol";

contract PrivateVoting is IPrivateVoting {
    bool public isSignupActive = true;
    IPoseidon public poseidon;

    string[] public votes;
    mapping(uint256 => bool) alreadyVotedNullifiers;

    constructor(IPoseidon _poseidon) {
        poseidon = _poseidon;
        initDefaults();
    }

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

    // ---- Merkle Tree ----
    //       layer              index      value
    mapping(uint256 => mapping(uint256 => uint256)) public merkleTree;
    uint256 public currentDepth = 0;
    uint256 public constant MAX_DEPTH = 32;

    function getOrDefault(
        uint256 layer,
        uint256 index
    ) public returns (uint256) {
        uint256 node = merkleTree[layer][index];
        if (node == 0) {
            return defaults[layer];
        } else {
            return node;
        }
    }

    function getRootOfTree() public returns (uint256) {
        return merkleTree[currentDepth][0];
    }

    // pass hashed value
    function insertToTree() private {
        // TODO this is the hard part
    }

    // ---- Defaults ----
    // what is default:
    // layer 0: 0
    // layer 1: poseidon(0,0)
    // layer 2: poseidon(poseidon(0,0),poseidon(0,0))

    // index is layer
    uint256[MAX_DEPTH] defaults;

    // [0..MAX_DEPTH]
    function initDefaults() public returns (uint256) {
        defaults[0] = 0;
        for (uint256 i = 1; i < MAX_DEPTH; i++) {
            defaults[i] = hash(defaults[i - 1], defaults[i - 1]);
        }
    }

    // high level function for easier use
    function hash(uint256 left, uint256 right) private view returns (uint256) {
        return poseidon.poseidon([left, right]);
    }
}
