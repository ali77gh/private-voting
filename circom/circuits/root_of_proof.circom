
pragma circom 2.0.0;

include "./posedon2.circom";

// According to README:
// Commitment is poseidon(secret, 1);
// Nullifier is poseidon(secret, 2);

// Calculates root of a given proof
template RootOfProof(Depth){
    signal input steps[Depth - 1];
    signal input sides[Depth - 1]; // 0 means left and 1 means right
    signal input secret;
    signal output root;
    signal output nullifier;

    signal commitment;
    component commitmentHash = Poseidon2();
    commitmentHash.left <== secret;
    commitmentHash.right <== 1;
    commitment <== commitmentHash.out; // TODO connect directly to calculated

    component nullifierHash = Poseidon2();
    nullifierHash.left <== secret;
    nullifierHash.right <== 2;
    nullifier <== nullifierHash.out;

    component hashers[Depth];
    signal calculated[Depth + 1];

    calculated[0] <== commitment;

    for (var i = 0; i < Depth - 1; i++) {
        hashers[i] = Poseidon2SwapInputs();
        hashers[i].a <== steps[i];
        hashers[i].b <== calculated[i];
        hashers[i].s <== sides[i];
        calculated[i + 1] <== hashers[i].out;
    }

    root <== calculated[Depth - 1];
}