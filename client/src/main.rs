use alloy::primitives::{U256, address};

mod contract;
mod hash;

#[tokio::main]
async fn main() {
    let privateVoting = contract::PrivateVotingContract::new(
        address!("0x1613beB3B2C4f22Ee086B2b38C1476A3cE7f78E8"),
        "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80".to_string(),
        None,
    )
    .await
    .unwrap();

    privateVoting.signup(U256::from(1)).await.unwrap();

    println!("commitments:");
    for commitment in privateVoting.get_commitments().await.unwrap() {
        println!("- {}", commitment);
    }
}
