// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

interface IPoseidon {
    function poseidon(uint256[2] memory input) external returns (uint256);
}
