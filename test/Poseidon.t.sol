// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {IPoseidon} from "../src/IPoseidon.sol";
import {console} from "forge-std/console.sol";

contract PrivateVotingTest is Test {
    IPoseidon public poseidon;
    address public poseidonAddress;

    function setUp() public {
        string memory poseidonHex = vm.readFile(
            "bytecodes/poseidon_runtime.hex"
        );
        bytes memory poseidonBytes = vm.parseBytes(poseidonHex);
        poseidonAddress = address(0x1234);

        vm.etch(poseidonAddress, poseidonBytes);
        poseidon = IPoseidon(poseidonAddress);
    }

    function test_hashFunction() public {
        assertEq(
            poseidon.poseidon([uint256(5), uint256(77)]),
            6008246173323011098915936938805752727781568490715388424063708882447636047656
        );
    }
}
