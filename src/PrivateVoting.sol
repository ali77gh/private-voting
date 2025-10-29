// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPrivateVoting} from "./IPrivateVoting.sol";

contract PrivateVoting is IPrivateVoting {
    bool public isSignupActive = true;

    function signup(uint256 commitment) external {
        require(isSignupActive, "signup is not active anymore");
        // TODO
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
        // TODO
    }
}
