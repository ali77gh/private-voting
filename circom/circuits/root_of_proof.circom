
pragma circom 2.0.0;

include "./posedon2.circom";


// calculates root of a given proof
template RootOfProof(Depth){
    signal input steps[Depth - 1];
    signal input sides[Depth - 1]; // 0 means left and 1 means right
    signal input value;
    signal output root;

    component hashers[Depth];
    signal calculated[Depth + 1];

    calculated[0] <== value;

    for (var i = 0; i < Depth - 1; i++) {
        hashers[i] = Poseidon2SwapInputs();
        hashers[i].a <== steps[i];
        hashers[i].b <== calculated[i];
        hashers[i].s <== sides[i];
        calculated[i + 1] <== hashers[i].out;
    }

    root <== calculated[Depth - 1];
}