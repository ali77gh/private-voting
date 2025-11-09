// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPrivateVoting} from "./IPrivateVoting.sol";
import {IPoseidon} from "./IPoseidon.sol";

contract PrivateVoting is IPrivateVoting {
    bool public isSignupActive = true;
    IPoseidon public poseidon;

    string[] public votes;
    mapping(uint256 => bool) alreadyVotedNullifiers;

    event Signup(uint256 commitment);

    constructor(IPoseidon _poseidon) {
        poseidon = _poseidon;
        initDefaults();
    }

    function signup(uint256 commitment) external {
        require(isSignupActive, "signup is not active anymore");
        insertToTree(commitment);
        emit Signup(commitment);
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
    uint256 public layer0Length = 0;
    uint256 public constant MAX_DEPTH = 32;

    function getOrDefault(
        uint256 layer,
        uint256 index
    ) public view returns (uint256) {
        uint256 node = merkleTree[layer][index];
        if (node == 0) {
            return defaults[layer];
        } else {
            return node;
        }
    }

    function getRootOfTree() public view returns (uint256) {
        return merkleTree[currentDepth][0];
    }

    // pass hashed value
    function insertToTree(uint256 commitment) private {
        // inserting commitment to layer 0 (no hash needed commitment is already a hashed value)
        merkleTree[0][layer0Length] = commitment;
        layer0Length += 1;

        // initial value is index of inserted item
        uint256 pointer = layer0Length - 1;
        bool isLeft = pointer % 2 == 0;
        for (uint256 i = 0; i <= currentDepth; i++) {
            isLeft = pointer % 2 == 0;
            if (isLeft) {
                uint256 left = merkleTree[i][pointer];
                uint256 right = defaults[i];
                merkleTree[i + 1][pointer / 2] = hash(left, right);
            } else {
                uint256 left = merkleTree[i][pointer - 1];
                uint256 right = merkleTree[i][pointer];
                merkleTree[i + 1][pointer / 2] = hash(left, right);
            }
            pointer /= 2;
        }

        if (isLeft) {
            currentDepth += 1;
        }
    }

    // ---- Defaults ----
    // what is default:
    // layer 0: 0
    // layer 1: poseidon(0,0)
    // layer 2: poseidon(poseidon(0,0),poseidon(0,0))

    // index is layer
    uint256[MAX_DEPTH] defaults;

    // [0..MAX_DEPTH]
    function initDefaults() public {
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
