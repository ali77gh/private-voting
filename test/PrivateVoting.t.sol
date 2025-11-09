// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PrivateVoting} from "../src/PrivateVoting.sol";
import {IPoseidon} from "../src/IPoseidon.sol";

contract PrivateVotingTest is Test {
    PrivateVoting public privateVoting;

    function setUp() public {
        privateVoting = new PrivateVoting(new FakeHash());
    }

    function test_merkleTreeTestEven() public {
        privateVoting.signup(1);
        privateVoting.signup(10);
        privateVoting.signup(100);
        privateVoting.signup(1000);

        // layer 0
        assertEq(privateVoting.getOrDefault(0, 0), 1);
        assertEq(privateVoting.getOrDefault(0, 1), 10);
        assertEq(privateVoting.getOrDefault(0, 2), 100);
        assertEq(privateVoting.getOrDefault(0, 3), 1000);
        assertEq(privateVoting.getOrDefault(0, 4), 0); // out of range

        // layer 1
        assertEq(privateVoting.getOrDefault(1, 0), 11);
        assertEq(privateVoting.getOrDefault(1, 1), 1100);
        assertEq(privateVoting.getOrDefault(1, 2), 0); // out of range

        // layer 2 (last layer)
        assertEq(privateVoting.getOrDefault(2, 0), 1111); // this is actually root
        assertEq(privateVoting.getOrDefault(2, 1), 0); // out of range

        assertEq(privateVoting.getRootOfTree(), 1111);
    }

    function test_merkleTreeTestOdd() public {
        privateVoting.signup(1);
        privateVoting.signup(10);
        privateVoting.signup(100);
        privateVoting.signup(1000);
        privateVoting.signup(10000);

        // layer 0
        assertEq(privateVoting.getOrDefault(0, 0), 1);
        assertEq(privateVoting.getOrDefault(0, 1), 10);
        assertEq(privateVoting.getOrDefault(0, 2), 100);
        assertEq(privateVoting.getOrDefault(0, 3), 1000);
        assertEq(privateVoting.getOrDefault(0, 4), 10000);
        assertEq(privateVoting.getOrDefault(0, 5), 0); // out of range

        // layer 1
        assertEq(privateVoting.getOrDefault(1, 0), 11);
        assertEq(privateVoting.getOrDefault(1, 1), 1100);
        assertEq(privateVoting.getOrDefault(1, 2), 10000); // 10000 + 0
        assertEq(privateVoting.getOrDefault(1, 3), 0); // out of range

        // layer 2
        assertEq(privateVoting.getOrDefault(2, 0), 1111);
        assertEq(privateVoting.getOrDefault(2, 1), 10000);
        assertEq(privateVoting.getOrDefault(2, 2), 0); // out of range

        // layer 3 (last layer)
        assertEq(privateVoting.getOrDefault(3, 0), 11111);
        assertEq(privateVoting.getOrDefault(3, 1), 0); // out of range

        assertEq(privateVoting.getRootOfTree(), 11111);
    }
}

contract FakeHash is IPoseidon {
    function poseidon(uint256[2] memory input) external pure returns (uint256) {
        return input[0] + input[1];
    }
}
