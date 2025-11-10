//! Demonstrates reading a contract by fetching the WETH balance of an address.
use alloy::{
    primitives::{Address, U256},
    providers::{ProviderBuilder, RootProvider, fillers::*},
    sol,
};
use std::error::Error;

use crate::contract::PrivateVoting::PrivateVotingInstance;

/// Allow Contract type wrapper
pub struct PrivateVotingContract(AlloyContractType);

impl PrivateVotingContract {
    /// default rpc_url is local anvil
    pub async fn new(
        contract_address: Address,
        rpc_url: Option<String>,
    ) -> Result<Self, Box<dyn Error>> {
        let rpc_url = rpc_url.unwrap_or("http://127.0.0.1:8545".to_string());
        let provider = ProviderBuilder::new().connect(&rpc_url).await?;

        // Instantiate the contract instance.
        let contract = PrivateVoting::new(contract_address, provider);

        Ok(Self(contract))
    }

    pub async fn get_commitments(&self) -> Result<Vec<U256>, Box<dyn Error>> {
        let c = self.0.Signup_filter().query().await?;
        Ok(c.iter().map(|x| x.0.commitment).collect())
    }
}

// Generate the contract bindings for the ERC20 interface.
sol! {
   // The `rpc` attribute enables contract interaction via the provider.
   #[sol(rpc)]
   contract PrivateVoting {
      event Signup(uint256 commitment);
   }
}

type AlloyContractType = PrivateVotingInstance<
    FillProvider<
        JoinFill<
            alloy::providers::Identity,
            JoinFill<GasFiller, JoinFill<BlobGasFiller, JoinFill<NonceFiller, ChainIdFiller>>>,
        >,
        RootProvider,
    >,
>;
