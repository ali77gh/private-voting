// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PrivateVoting} from "../src/PrivateVoting.sol";
import {IPoseidon} from "../src/IPoseidon.sol";
import {console} from "forge-std/console.sol";

contract PrivateVotingScript is Script {
    function run() public {
        // --- Step 1 upload Poseidon (hex)
        uint256 deployerPrivateKey = vm.envUint("PK");

        bytes memory bytecode = vm.parseBytes(
            vm.readFile("./bytecodes/copy_poseidon.hex")
        );

        vm.startBroadcast(deployerPrivateKey);

        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.stopBroadcast();

        require(deployed != address(0), "Deployment failed");
        console.log("Poseidon Contract deployed at:", deployed);

        IPoseidon poseidon = IPoseidon(deployed);

        // --- Step 2 upload PrivateVoting (.sol)
        vm.startBroadcast(deployerPrivateKey);

        PrivateVoting privateVoting = new PrivateVoting(poseidon);
        console.log(
            "PrivateVoting Contract deployed at:",
            address(privateVoting)
        );
        vm.stopBroadcast();
    }
}
