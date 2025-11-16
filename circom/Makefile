
compile:
	mkdir -p tmp
# 	circom ./circuits/main.circom --r1cs --wasm --sym --c -o tmp
	circom ./circuits/main.circom --r1cs --wasm --sym -o tmp

witness:
	node ./tmp/main_js/generate_witness.js ./tmp/main_js/main.wasm input.json ./tmp/witness.wtns

trusted_setup:
	mkdir -p out
	npx snarkjs powersoftau new bn128 12 ./tmp/pot12_0000.ptau -v
	npx snarkjs powersoftau prepare phase2 ./tmp/pot12_0000.ptau ./tmp/pot12_final.ptau -v
	npx snarkjs groth16 setup ./tmp/main.r1cs ./tmp/pot12_final.ptau ./tmp/main_0000.zkey
	npx snarkjs zkey export verificationkey ./tmp/main_0000.zkey ./out/verification_key.json

generate_proof:
	npx snarkjs groth16 prove ./tmp/main_0000.zkey ./tmp/witness.wtns ./out/proof.json ./out/public.json

verify_proof:
	npx snarkjs groth16 verify ./out/verification_key.json ./out/public.json ./out/proof.json

generate_verifier:
	npx snarkjs zkey export solidityverifier ./tmp/main_0000.zkey ./out/verifier.sol

all:
	make compile 
	make witness
	make trusted_setup
	make generate_proof 
	make verify_proof 
	make generate_verifier