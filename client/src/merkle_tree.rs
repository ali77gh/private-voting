use std::error::Error;

use alloy::primitives::U256;

use crate::hash::Hasher;

pub struct MerkleTree {
    hasher: Hasher,
    tree: Vec<Vec<U256>>,
    defaults: Vec<U256>,
}

impl MerkleTree {
    pub fn new() -> Result<Self, Box<dyn Error>> {
        Ok(Self {
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

    pub fn print_tree(&self) {
        println!("--- tree ---");
        for layer in &self.tree {
            for i in layer {
                print!("{i} ");
            }
            println!();
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn defaults_test() {
        let mut merkle = MerkleTree::new().unwrap();
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
        let mut merkle = MerkleTree::new().unwrap();
        let mut hasher = Hasher::new().unwrap();

        merkle.add_leaf(U256::from(76));
        merkle.add_leaf(U256::from(77));
        merkle.add_leaf(U256::from(78));

        merkle.calculate().unwrap();

        // manual calculation
        //      root
        //  right   left
        // 76  77  78   0
        let left = hasher.hash(U256::from(76), U256::from(77)).unwrap();
        let right = hasher.hash(U256::from(78), U256::ZERO).unwrap();
        let correct_root = hasher.hash(left, right).unwrap();

        assert_eq!(merkle.root(), correct_root);
    }
}
