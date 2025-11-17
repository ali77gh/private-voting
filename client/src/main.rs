use std::fs;

use alloy::primitives::U256;

use crate::merkle_tree::{CircomInputJson, MerkleTree};

mod contract;
mod hash;
mod merkle_tree;

#[tokio::main]
async fn main() {
    // let private_voting = contract::PrivateVotingContract::new(
    //     address!("0x5eb3Bc0a489C5A8288765d2336659EbCA68FCd00"),
    //     "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80".to_string(),
    //     None,
    // )
    // .await
    // .unwrap();

    // private_voting.signup(U256::from(76)).await.unwrap();
    // private_voting.signup(U256::from(77)).await.unwrap();
    // private_voting.signup(U256::from(78)).await.unwrap();

    // let commitments = private_voting.get_commitments().await.unwrap();

    // println!("commitments:");
    // for commitment in &commitments {
    //     println!("- {}", commitment);
    // }

    let mut merkle_tree = MerkleTree::new(32).unwrap();
    // merkle_tree.add_leafs(commitments);
    merkle_tree.add_leaf(U256::from(76));
    merkle_tree.add_leaf(U256::from(77));
    merkle_tree.add_leaf(U256::from(78));
    merkle_tree.calculate().unwrap();

    // let contract_root = private_voting.get_root().await.unwrap();

    // assert_eq!(merkle_tree.root(), contract_root);
    println!("root: {}", merkle_tree.root());

    let proof = merkle_tree.generate_proof(2);
    println!("proof:\n{:?}", &proof);

    let json = CircomInputJson::new(proof, merkle_tree.root())
        .to_json()
        .unwrap();
    fs::write("./input.json", json).unwrap();
}
