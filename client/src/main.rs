use alloy::primitives::address;

mod contract;

#[tokio::main]
async fn main() {
    let privateVoting = contract::PrivateVotingContract::new(
        address!("0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"),
        None,
    )
    .await
    .unwrap();

    println!("commitments:");
    for commitment in privateVoting.get_commitments().await.unwrap() {
        println!("- {}", commitment);
    }
}
