build:
	forge build

tests:
	forge test

# needs PK env variable
deploy_anvil:

	forge script script/PrivateVoting.s.sol:PrivateVotingScript \
        	--rpc-url http://127.0.0.1:8545 \
        	--private-key $(PK) \
        	--broadcast
