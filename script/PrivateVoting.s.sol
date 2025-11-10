// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PrivateVoting} from "../src/PrivateVoting.sol";
import {IPoseidon} from "../src/IPoseidon.sol";
import {console} from "forge-std/console.sol";

contract PrivateVotingScript is Script {
    function run() public {
        // --- Step 1 upload Poseidon (hex)
        bytes memory bytecode = vm.parseBytes(
            vm.readFile("./bytecodes/copy_poseidon.hex")
        );

        vm.startBroadcast();

        address poseidonAddr;
        assembly {
            poseidonAddr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.stopBroadcast();

        require(poseidonAddr != address(0), "Deployment failed");
        console.log("Poseidon Contract deployed at:", poseidonAddr);

        IPoseidon poseidon = IPoseidon(poseidonAddr);

        // --- Step 2 upload PrivateVoting (.sol)
        vm.startBroadcast();

        PrivateVoting privateVoting = new PrivateVoting(poseidon);
        vm.stopBroadcast();
        address privateVotingAddr = address(privateVoting);
        require(privateVotingAddr != address(0), "Deployment failed");
        console.log("PrivateVoting Contract deployed at:", privateVotingAddr);
    }
}
