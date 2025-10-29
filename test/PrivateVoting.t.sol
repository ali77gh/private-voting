// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PrivateVoting} from "../src/PrivateVoting.sol";

contract PrivateVotingTest is Test {
    PrivateVoting public privateVoting;

    function setUp() public {
        privateVoting = new PrivateVoting();
    }

    function test_() public {}
}
