
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
