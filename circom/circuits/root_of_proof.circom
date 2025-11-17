
pragma circom 2.0.0;

include "./posedon2.circom";


// calculates root of a given proof
template RootOfProof(Depth){
    signal input steps[Depth];
    signal input sides[Depth]; // 0 means left and 1 means right
    signal output root;

    component hashers[Depth];
    signal calculated[Depth + 1];

    calculated[0] <== steps[0];

    for (var i = 0; i < Depth; i++) {
        hashers[i] = Poseidon2SwapInputs();
        hashers[i].a <== steps[i];
        hashers[i].b <== calculated[i];
        hashers[i].s <== sides[i];
        calculated[i + 1] <== hashers[i].out;
    }

    root <== calculated[Depth];
}