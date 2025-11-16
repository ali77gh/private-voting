pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template Poseidon2(){
    signal input left;
    signal input right;
    signal output out;

    component p = Poseidon(2);
    p.inputs[0] <== left;
    p.inputs[1] <== right;

    out <== p.out;
}

// if s == 0 returns poseidon(a, b)
// if s == 1 returns poseidon(b, a)
template Poseidon2SwapInputs(){
    signal input a;
    signal input b;
    signal input s; // side (0 means left and 1 means right)
    signal output out;

    // make sure s is (0|1)
    0 === (1 - s) * s;

    signal left;
    signal right;

    left  <-- (s * b) + ((1 - s) * a);
    right <-- (s * a) + ((1 - s) * b);

    component p = Poseidon2();
    p.left <== left;
    p.right <== right;

    out <== p.out;
}