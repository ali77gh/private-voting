pragma circom 2.0.0;

include "./posedon2.circom";

template VerifyTree{
    signal input a;
    signal input b;
    signal output c;

    component hash = Poseidon2();
    hash.left <== a;
    hash.right <== b;
    c <== hash.out;
}

component main = VerifyTree();