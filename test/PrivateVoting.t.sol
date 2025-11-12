// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PrivateVoting} from "../src/PrivateVoting.sol";
import {IPoseidon} from "../src/IPoseidon.sol";

contract PrivateVotingTest is Test {
    PrivateVoting public fakePrivateVoting;
    PrivateVoting public privateVoting;
    IPoseidon public poseidon;

    function setUp() public {
        fakePrivateVoting = new PrivateVoting(new FakeHash());

        string memory poseidonHex = vm.readFile("bytecodes/poseidon.hex");
        bytes memory poseidonBytes = vm.parseBytes(poseidonHex);
        address poseidonAddress = address(0x1234);

        vm.etch(poseidonAddress, poseidonBytes);
        poseidon = IPoseidon(poseidonAddress);
        privateVoting = new PrivateVoting(poseidon);
    }

    function test_fakeMerkleTreeEven() public {
        fakePrivateVoting.signup(1);
        fakePrivateVoting.signup(10);
        fakePrivateVoting.signup(100);
        fakePrivateVoting.signup(1000);

        // layer 0
        assertEq(fakePrivateVoting.getOrDefault(0, 0), 1);
        assertEq(fakePrivateVoting.getOrDefault(0, 1), 10);
        assertEq(fakePrivateVoting.getOrDefault(0, 2), 100);
        assertEq(fakePrivateVoting.getOrDefault(0, 3), 1000);
        assertEq(fakePrivateVoting.getOrDefault(0, 4), 0); // out of range

        // layer 1
        assertEq(fakePrivateVoting.getOrDefault(1, 0), 11);
        assertEq(fakePrivateVoting.getOrDefault(1, 1), 1100);
        assertEq(fakePrivateVoting.getOrDefault(1, 2), 0); // out of range

        // layer 2 (last layer)
        assertEq(fakePrivateVoting.getOrDefault(2, 0), 1111); // this is actually root
        assertEq(fakePrivateVoting.getOrDefault(2, 1), 0); // out of range

        assertEq(fakePrivateVoting.getRootOfTree(), 1111);
    }

    function test_fakeMerkleTreeOdd() public {
        fakePrivateVoting.signup(1);
        fakePrivateVoting.signup(10);
        fakePrivateVoting.signup(100);
        fakePrivateVoting.signup(1000);
        fakePrivateVoting.signup(10000);

        // layer 0
        assertEq(fakePrivateVoting.getOrDefault(0, 0), 1);
        assertEq(fakePrivateVoting.getOrDefault(0, 1), 10);
        assertEq(fakePrivateVoting.getOrDefault(0, 2), 100);
        assertEq(fakePrivateVoting.getOrDefault(0, 3), 1000);
        assertEq(fakePrivateVoting.getOrDefault(0, 4), 10000);
        assertEq(fakePrivateVoting.getOrDefault(0, 5), 0); // out of range

        // layer 1
        assertEq(fakePrivateVoting.getOrDefault(1, 0), 11);
        assertEq(fakePrivateVoting.getOrDefault(1, 1), 1100);
        assertEq(fakePrivateVoting.getOrDefault(1, 2), 10000); // 10000 + 0
        assertEq(fakePrivateVoting.getOrDefault(1, 3), 0); // out of range

        // layer 2
        assertEq(fakePrivateVoting.getOrDefault(2, 0), 1111);
        assertEq(fakePrivateVoting.getOrDefault(2, 1), 10000);
        assertEq(fakePrivateVoting.getOrDefault(2, 2), 0); // out of range

        // layer 3 (last layer)
        assertEq(fakePrivateVoting.getOrDefault(3, 0), 11111);
        assertEq(fakePrivateVoting.getOrDefault(3, 1), 0); // out of range

        assertEq(fakePrivateVoting.getRootOfTree(), 11111);
    }

    function test_defaults() public {
        uint256 layer1 = poseidon.poseidon([uint256(0), uint256(0)]);
        uint256 layer2 = poseidon.poseidon([layer1, layer1]);
        uint256 layer3 = poseidon.poseidon([layer2, layer2]);

        assertEq(privateVoting.getDefault(0), 0);
        assertEq(privateVoting.getDefault(1), layer1);
        assertEq(privateVoting.getDefault(2), layer2);
        assertEq(privateVoting.getDefault(3), layer3);
    }

    function test_merkleTreeEven() public {
        privateVoting.signup(76);
        privateVoting.signup(77);
        privateVoting.signup(78);
        privateVoting.signup(79);

        // layer 0
        assertEq(privateVoting.getOrDefault(0, 0), 76);
        assertEq(privateVoting.getOrDefault(0, 1), 77);
        assertEq(privateVoting.getOrDefault(0, 2), 78);
        assertEq(privateVoting.getOrDefault(0, 3), 79);

        // layer 1
        uint256 left = poseidon.poseidon([uint256(76), uint256(77)]);
        uint256 right = poseidon.poseidon([uint256(78), uint256(79)]);

        assertEq(privateVoting.getOrDefault(1, 0), left);
        assertEq(privateVoting.getOrDefault(1, 1), right);

        // layer 2 (root)
        uint256 root = poseidon.poseidon([left, right]);
        assertEq(privateVoting.getOrDefault(2, 0), root);
        assertEq(privateVoting.getCurrentDepth(), 2);
        assertEq(privateVoting.getRootOfTree(), root);
    }

    function test_merkleTreeOdd() public {
        privateVoting.signup(76);
        privateVoting.signup(77);
        privateVoting.signup(78);

        // layer 0
        assertEq(privateVoting.getOrDefault(0, 0), 76);
        assertEq(privateVoting.getOrDefault(0, 1), 77);
        assertEq(privateVoting.getOrDefault(0, 2), 78);

        // layer 1
        uint256 left = poseidon.poseidon([uint256(76), uint256(77)]);
        uint256 right = poseidon.poseidon([uint256(78), uint256(0)]);

        assertEq(privateVoting.getOrDefault(1, 0), left);
        assertEq(privateVoting.getOrDefault(1, 1), right);

        // layer 2 (root)
        uint256 root = poseidon.poseidon([left, right]);
        assertEq(privateVoting.getOrDefault(2, 0), root);
        assertEq(privateVoting.getCurrentDepth(), 2);
        assertEq(privateVoting.getRootOfTree(), root);
    }
}

contract FakeHash is IPoseidon {
    function poseidon(uint256[2] memory input) external pure returns (uint256) {
        return input[0] + input[1];
    }
}
