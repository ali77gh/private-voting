use alloy::primitives::U256;

#[derive(Default, Debug, Clone, PartialEq, Eq)]
pub struct MerkleProof {
    value: U256,
    steps: Vec<MerkleProofStep>,
}

impl MerkleProof {
    pub fn new(value: U256) -> Self {
        MerkleProof {
            value,
            steps: vec![],
        }
    }

    pub fn push(&mut self, hashed: U256, side: Side) {
        self.steps.push(MerkleProofStep {
            side,
            value: hashed,
        });
    }

    pub fn value(&self) -> U256 {
        self.value
    }

    pub fn steps(&self) -> &[MerkleProofStep] {
        &self.steps
    }
}

#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
pub struct MerkleProofStep {
    side: Side,
    value: U256,
}

impl MerkleProofStep {
    pub fn side(&self) -> Side {
        self.side
    }

    pub fn value(&self) -> U256 {
        self.value
    }
}

#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
pub enum Side {
    Left,
    Right,
}
