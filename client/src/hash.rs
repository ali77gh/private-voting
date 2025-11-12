use std::error::Error;

use alloy::primitives::U256;
use ark_bn254::{Fr, FrConfig};
use ark_ff::{Fp, MontBackend};
use light_poseidon::{Poseidon, PoseidonBytesHasher};

pub struct Hasher(Poseidon<Fp<MontBackend<FrConfig, 4>, 4>>);

impl Hasher {
    pub fn new() -> Result<Self, Box<dyn Error>> {
        Ok(Hasher(Poseidon::<Fr>::new_circom(2)?))
    }

    pub fn hash(&mut self, a: U256, b: U256) -> Result<U256, Box<dyn Error>> {
        let a = a.to_be_bytes::<32>();
        let b = b.to_be_bytes::<32>();

        let hashed = self.0.hash_bytes_be(&[&a, &b])?;

        Ok(U256::from_be_bytes(hashed))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn poseidon_test() {
        let mut hasher = Hasher::new().unwrap();
        let a = U256::from(5);
        let b = U256::from(77);
        let answer = U256::from_str_radix(
            "6008246173323011098915936938805752727781568490715388424063708882447636047656",
            10,
        )
        .unwrap();
        assert_eq!(hasher.hash(a, b).unwrap(), answer);
    }
}
