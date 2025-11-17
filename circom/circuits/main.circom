pragma circom 2.0.0;

include "./verify_proof.circom";
include "./root_of_proof.circom";

component main { public [ root ] } = VerifyProof(32);
