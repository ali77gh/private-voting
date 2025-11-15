use alloy::primitives::U256;

#[derive(Default, Debug, Clone, PartialEq, Eq)]
pub struct MerkleProof(pub Vec<MerkleProofStep>);

impl MerkleProof {
    pub fn new() -> Self {
        MerkleProof(vec![])
    }

    pub fn push(&mut self, hashed: U256, side: Side) {
        self.0.push(MerkleProofStep {
            side,
            value: hashed,
        });
    }

    pub fn value(&self) -> U256 {
        self.0.first().unwrap().value
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

impl From<usize> for Side {
    fn from(value: usize) -> Self {
        if value % 2 == 0 {
            Self::Left
        } else {
            Self::Right
        }
    }
}
