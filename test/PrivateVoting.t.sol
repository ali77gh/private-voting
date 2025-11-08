// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PrivateVoting} from "../src/PrivateVoting.sol";
import {IPoseidon} from "../src/IPoseidon.sol";

contract PrivateVotingTest is Test {
    PrivateVoting public privateVoting;

    function setUp() public {
        // poseidon setup
        string memory poseidonHex = vm.readFile("bytecodes/poseidon.hex");
        bytes memory poseidonBytes = vm.parseBytes(poseidonHex);
        address poseidonAddress = address(0x1234);

        vm.etch(poseidonAddress, poseidonBytes);
        IPoseidon poseidon = IPoseidon(poseidonAddress);

        privateVoting = new PrivateVoting(poseidon);
    }

    function test_() public {}
}
