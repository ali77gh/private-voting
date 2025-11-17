use alloy::primitives::U256;

use crate::{hash::Hasher, merkle_tree::MerkleProof};

pub fn verify(root: U256, proof: MerkleProof) -> bool {
    let mut hasher = Hasher::new().unwrap();

    let mut calculated_root = proof.value();
    for step in proof.steps().iter() {
        calculated_root = match step.side() {
            super::Side::Left => hasher.hash(step.value(), calculated_root).unwrap(),
            super::Side::Right => hasher.hash(calculated_root, step.value()).unwrap(),
        }
    }

    calculated_root == root
}

#[cfg(test)]
mod tests {
    use crate::merkle_tree::{MerkleTree, Side};

    use super::*;

    #[test]
    fn verify_valid_proof_test() {
        let mut merkle = MerkleTree::new(3).unwrap();

        merkle.add_leaf(U256::from(76));
        merkle.add_leaf(U256::from(77));
        merkle.add_leaf(U256::from(78));

        merkle.calculate().unwrap();
        let proof = merkle.generate_proof(2); // 78
        let verified = verify(merkle.root(), proof);
        assert!(verified);
    }

    #[test]
    fn verify_invalid_proof_test() {
        let mut proof = MerkleProof::new(U256::from(256));

        proof.push(U256::from(100), Side::Left);
        proof.push(U256::from(200), Side::Right);

        assert_eq!(verify(U256::from(123), proof), false);
    }
}
