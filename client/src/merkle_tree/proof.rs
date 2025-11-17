use std::error::Error;

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

impl From<Side> for u8 {
    // in circom circuit VerifyProof we don't have enum and we use numbers to specify side
    // 0 => Left
    // 1 => Right
    fn from(value: Side) -> Self {
        match value {
            Side::Left => 0,
            Side::Right => 1,
        }
    }
}

#[derive(serde::Serialize)]
pub struct CircomInputJson {
    steps: Vec<String>,
    sides: Vec<String>,
    root: String,
}

impl CircomInputJson {
    pub fn new(proof: MerkleProof, root: U256) -> Self {
        let mut steps = Vec::<String>::new();
        let mut sides = Vec::<String>::new();

        for step in proof.steps() {
            steps.push(step.value().to_string());
            sides.push(u8::from(step.side()).to_string());
        }

        CircomInputJson {
            steps,
            sides,
            root: root.to_string(),
        }
    }

    pub fn to_json(&self) -> Result<String, Box<dyn Error>> {
        Ok(serde_json::to_string_pretty(self)?)
    }
}
