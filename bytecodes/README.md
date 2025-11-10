# ByteCodes

We have two hex file here

1. poseidon.hex
2. copy_poseidon.hex
   
difference is a copy operation in the beginning
```
38600c60003961260f6000f3
```
So:
```
copy operation + poseidon.hex => copy_poseidon.hex 
```

Note: `poseidon.hex` used in test `Poseidon.t.sol` and `copy_poseidon` is used in script file `PrivateVoting.s.sol`

Note: `poseidon.hex` is pure poseidon function and `copy_poseidon` is a function that returns poseidon code