
include "./root_of_proof.circom";

// proof that `commitment` exists in tree and nullifier
// We don't need full tree, root is enough
template VerifyProof(Depth){
    signal input steps[Depth - 1];
    signal input sides[Depth - 1]; // 0 means left and 1 means right
    signal input secret;
    signal input root;
    signal output nullifier;

    component root_of_proof = RootOfProof(Depth);
    root_of_proof.steps <== steps;
    root_of_proof.sides <== sides;
    root_of_proof.secret <== secret;

    root_of_proof.root === root;
    nullifier <== root_of_proof.nullifier;
}