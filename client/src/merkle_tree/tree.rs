use std::error::Error;

use alloy::primitives::U256;

use crate::{
    hash::Hasher,
    merkle_tree::{MerkleProof, Side},
};

pub struct MerkleTree {
    hasher: Hasher,
    depth: usize,
    tree: Vec<Vec<U256>>,
    defaults: Vec<U256>,
}

impl MerkleTree {
    pub fn new(depth: usize) -> Result<Self, Box<dyn Error>> {
        Ok(Self {
            depth,
            hasher: Hasher::new()?,
            tree: vec![vec![]],            // first layer (for leafs)
            defaults: vec![U256::from(0)], // first layer default is always zero
        })
    }

    pub fn add_leaf(&mut self, value: U256) {
        // Safety: using unwrap is OK as far as we initialize first layer in `new` function
        self.tree.first_mut().unwrap().push(value);
    }

    pub fn add_leafs(&mut self, values: Vec<U256>) {
        for value in values {
            self.add_leaf(value);
        }
    }

    pub fn calculate(&mut self) -> Result<(), Box<dyn Error>> {
        let mut i = 0usize;
        while self.tree[i].len() != 1 {
            if self.tree[i].len() % 2 == 1 {
                let d = self.defaults(i)?;
                self.tree[i].push(d);
            }
            let next_layer: Result<Vec<U256>, Box<dyn Error>> = self.tree[i]
                .chunks(2)
                .map(|x| self.hasher.hash(x[0], x[1]))
                .collect();
            self.tree.push(next_layer?);
            i += 1;
        }

        // calculate rest of nodes to the depth
        //                          layer[i][0]
        //                         /   |
        // last layer single element   default[i - 1]
        while self.tree.len() < self.depth {
            let default = self.defaults(i)?;
            let hash = self.hasher.hash(self.tree[i][0], default)?;
            self.tree.push(vec![hash]);
            i += 1;
        }

        Ok(())
    }

    pub fn defaults(&mut self, layer: usize) -> Result<U256, Box<dyn Error>> {
        while self.defaults.get(layer) == None {
            // Safety: this unwrap() is safe because I added first element to defaults in `new` function
            let last = *self.defaults.last().unwrap();
            let new_default = self.hasher.hash(last, last)?;
            self.defaults.push(new_default);
        }

        Ok(self.defaults[layer])
    }

    pub fn root(&self) -> U256 {
        *self.tree.last().unwrap().first().unwrap()
    }

    pub fn generate_proof(&mut self, index: usize) -> MerkleProof {
        let value = self.tree.first().unwrap()[index];
        let mut proof = MerkleProof::new(value);

        let mut index = index;
        for i in 0..self.tree.len() - 1 {
            let layer = &self.tree[i];
            if index % 2 == 0 {
                if layer.len() == 1 {
                    let default = self.defaults(i).unwrap();
                    proof.push(default, Side::Right);
                } else {
                    proof.push(layer[index + 1], Side::Right);
                }
            } else {
                proof.push(layer[index - 1], Side::Left);
            };
            index /= 2;
        }
        proof
    }

    pub fn print_tree(&self) {
        println!("--- tree ---");
        for (layer_index, layer) in self.tree.iter().enumerate() {
            print!("layer: {}, len: {} content: ", layer_index, layer.len());
            for i in layer {
                print!("{i} ");
            }
            println!();
        }
        println!("--- end of tree ---");
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn defaults_test() {
        let mut merkle = MerkleTree::new(3).unwrap();
        let mut hasher = Hasher::new().unwrap();

        let layer1 = hasher.hash(U256::ZERO, U256::ZERO).unwrap();
        let layer2 = hasher.hash(layer1, layer1).unwrap();
        let layer3 = hasher.hash(layer2, layer2).unwrap();

        assert_eq!(merkle.defaults(0).unwrap(), U256::ZERO);
        assert_eq!(merkle.defaults(1).unwrap(), layer1);
        assert_eq!(merkle.defaults(2).unwrap(), layer2);
        assert_eq!(merkle.defaults(3).unwrap(), layer3);
    }

    #[test]
    fn calculation_test() {
        let mut merkle = MerkleTree::new(3).unwrap();
        let mut hasher = Hasher::new().unwrap();

        merkle.add_leaf(U256::from(76));
        merkle.add_leaf(U256::from(77));
        merkle.add_leaf(U256::from(78));

        merkle.calculate().unwrap();

        // manual calculation
        //      root
        //  left    right
        // 76  77  78    0
        let left = hasher.hash(U256::from(76), U256::from(77)).unwrap();
        let right = hasher.hash(U256::from(78), U256::ZERO).unwrap();
        let correct_root = hasher.hash(left, right).unwrap();

        assert_eq!(merkle.root(), correct_root);
    }

    /// This test makes sure root calculations continues to the depth
    /// And not stopped when layer.len == 1
    #[test]
    fn calculation_to_depth_test() {
        let mut merkle = MerkleTree::new(3).unwrap();
        let mut hasher = Hasher::new().unwrap();

        merkle.add_leaf(U256::from(76));
        merkle.add_leaf(U256::from(77));

        merkle.calculate().unwrap();

        // manual calculation
        // in this example left is not root and root is root :)
        // because depth is 3 and not two
        //      root
        //  left    right
        // 76  77  0     0
        let left = hasher.hash(U256::from(76), U256::from(77)).unwrap();
        let right = hasher.hash(U256::ZERO, U256::ZERO).unwrap();
        let correct_root = hasher.hash(left, right).unwrap();

        assert_eq!(merkle.defaults(1).unwrap(), right);
        assert_eq!(merkle.root(), correct_root);
    }

    #[test]
    fn proof_test() {
        let mut merkle = MerkleTree::new(3).unwrap();
        let mut hasher = Hasher::new().unwrap();

        merkle.add_leaf(U256::from(76));
        merkle.add_leaf(U256::from(77));
        merkle.add_leaf(U256::from(78));

        merkle.calculate().unwrap();

        // manual calculation
        //      root
        //  left    right
        // 76  77  78    0
        let left = hasher.hash(U256::from(76), U256::from(77)).unwrap();

        let proof = merkle.generate_proof(2); // 78

        assert_eq!(proof.steps().len(), 2);

        assert_eq!(proof.steps()[0].value(), U256::from(0));
        assert_eq!(proof.steps()[0].side(), Side::Right);

        assert_eq!(proof.steps()[1].value(), left);
        assert_eq!(proof.steps()[1].side(), Side::Left);

        assert_eq!(proof.value(), U256::from(78));
    }
}
