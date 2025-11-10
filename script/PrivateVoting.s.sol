// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PrivateVoting} from "../src/PrivateVoting.sol";
import {IPoseidon} from "../src/IPoseidon.sol";
import {console} from "forge-std/console.sol";

contract PrivateVotingScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PK");
        console.log(deployerPrivateKey);

        // Read hex file — relative to project root
        string memory bytecodePath = "./bytecodes/copy_poseidon.hex";
        string memory hexContent = vm.readFile(bytecodePath);
        bytes memory bytecode = vm.parseBytes(hexContent);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy via low-level CREATE
        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.stopBroadcast();

        require(deployed != address(0), "Deployment failed");
        console.log("Contract deployed at:", deployed);

        IPoseidon poseidon = IPoseidon(deployed);
        uint256 hashed = poseidon.poseidon([uint256(5), uint256(77)]);
        console.log(hashed);
    }
}
