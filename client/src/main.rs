use alloy::primitives::{U256, address};

use crate::merkle_tree::MerkleTree;

mod contract;
mod hash;
mod merkle_tree;

#[tokio::main]
async fn main() {
    let private_voting = contract::PrivateVotingContract::new(
        address!("0x5eb3Bc0a489C5A8288765d2336659EbCA68FCd00"),
        "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80".to_string(),
        None,
    )
    .await
    .unwrap();

    // private_voting.signup(U256::from(76)).await.unwrap();
    // private_voting.signup(U256::from(77)).await.unwrap();
    // private_voting.signup(U256::from(78)).await.unwrap();

    let commitments = private_voting.get_commitments().await.unwrap();

    println!("commitments:");
    for commitment in &commitments {
        println!("- {}", commitment);
    }

    let mut merkle_tree = MerkleTree::new().unwrap();
    merkle_tree.add_leafs(commitments);
    merkle_tree.calculate().unwrap();

    let contract_root = private_voting.get_root().await.unwrap();

    println!("{}", merkle_tree.root());
    println!("{}", contract_root);
}
