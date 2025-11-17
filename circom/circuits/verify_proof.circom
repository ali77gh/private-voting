
include "./root_of_proof.circom";

// proof that `value` exists in tree
// We don't need full tree, root is enough
template VerifyProof(Depth){
    signal input steps[Depth - 1];
    signal input sides[Depth - 1]; // 0 means left and 1 means right
    signal input value;
    signal input root;

    component root_of_proof = RootOfProof(Depth);
    root_of_proof.steps <== steps;
    root_of_proof.sides <== sides;
    root_of_proof.value <== value;

    root_of_proof.root === root;
}