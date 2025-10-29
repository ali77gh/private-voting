## Private Voting

## Merkle tree
2^n

               / \
              /   \
             /\   /\
            /\/\ /\/\
           C C C 0 00 0 0    

## keywords to study
1. Sparse Merkle Tree
1. Nullifier
1. MiMC7 in Solidity (Find yourself)
1. MiMC7 in Circom (https://github.com/tornadocash/tornado-core/blob/1ef6a263ac6a0e476d063fcb269a9df65a1bd56a/circuits/merkleTree.circom#L3)
1. Difference between signal output and public inputs in Circom

## Goal
Build a MiMC7 Sparse-Merkle-Tree in Solidity. MiMC7 is a 2-input Snark friendly hash function

Create a Solidity contract for voting.

signup(uint256 commitment) for users to add their commitment to the tree. A commitment is MiMC7(secret, 1)

finalize() to disallow adding more commitments to the tree

After tree is finalized, users can start voting.

vote(uint256[2] _pA, uint256[2][2] _pB, uint256[2] _pC, string vote, uint256 nullifier) where nullifier is MiMC7(secret, 2). The contract avoids using a nullifier more than once. The zero-knowledge proof circuit should get [tree_root, nullifier] as public inputs. The circuit checks if a user knows a secret which its MiMC7(secret, 1) exists in the tree and its MiMC7(secret, 2) is equal with the given public input.