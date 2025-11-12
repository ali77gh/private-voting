//! Demonstrates reading a contract by fetching the WETH balance of an address.
use alloy::{
    network::EthereumWallet,
    primitives::{Address, U256},
    providers::{Identity, ProviderBuilder, RootProvider, fillers::*},
    signers::local::PrivateKeySigner,
    sol,
};
use std::error::Error;

use crate::contract::PrivateVoting::{PrivateVotingInstance, Signup};

/// Allow Contract type wrapper
pub struct PrivateVotingContract(AlloyContractType);

impl PrivateVotingContract {
    /// default rpc_url is local anvil
    pub async fn new(
        contract_address: Address,
        private_key: String,
        rpc_url: Option<String>,
    ) -> Result<Self, Box<dyn Error>> {
        let signer: PrivateKeySigner = private_key.parse()?;

        let rpc_url = rpc_url.unwrap_or("http://127.0.0.1:8545".to_string());
        let provider = ProviderBuilder::new()
            .wallet(signer)
            .connect(&rpc_url)
            .await?;

        // Instantiate the contract instance.
        let contract = PrivateVoting::new(contract_address, provider);

        Ok(Self(contract))
    }

    pub async fn get_commitments(&self) -> Result<Vec<U256>, Box<dyn Error>> {
        let c = self
            .0
            .event_filter::<Signup>()
            .from_block(0u64)
            .query()
            .await?;
        // let c = self.0.Signup_filter().query().await?;
        Ok(c.iter().map(|x| x.0.commitment).collect())
    }

    pub async fn signup(&self, commitment: U256) -> Result<(), Box<dyn Error>> {
        self.0
            .signup(commitment)
            .send()
            .await?
            .get_receipt()
            .await?;
        Ok(())
    }

    pub async fn get_root(&self) -> Result<U256, Box<dyn Error>> {
        Ok(self.0.getRootOfTree().call().await?)
    }
}

// Generate the contract bindings for the ERC20 interface.
sol! {
   // The `rpc` attribute enables contract interaction via the provider.
   #[sol(rpc)]
   contract PrivateVoting {
        event Signup(uint256 commitment);
        function signup(uint256 commitment);
        function getRootOfTree() public view returns (uint256);
   }
}

type AlloyContractType = PrivateVotingInstance<
    FillProvider<
        JoinFill<
            JoinFill<
                Identity,
                JoinFill<GasFiller, JoinFill<BlobGasFiller, JoinFill<NonceFiller, ChainIdFiller>>>,
            >,
            WalletFiller<EthereumWallet>,
        >,
        RootProvider,
    >,
>;
