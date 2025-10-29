// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IPrivateVoting {
    function signup(uint256 commitment) external;

    function finalize() external;

    function vote(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        string memory voteValue,
        uint256 nullifier
    ) external;
}
