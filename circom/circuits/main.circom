pragma circom 2.0.0;

include "./verify_proof.circom";
include "./root_of_proof.circom";

component main  = RootOfProof(3);
// component main { public [ root ] } = VerifyProof(3);
