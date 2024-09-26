## halmos-differential-erc20

Halmos Differential Tests for Common ERC-20 Token Implementations

### Description

This test uses N `msg.senders` to execute N arbitrary calls (using the new `createCalldata` cheatcode) and 1 arbitrary staticcall to see if the view functions return the same thing after changing the state

### Notes

- Error messages won't be the same, so checking for call success & return value does not work if the call fails
- OpenZeppelin will revert when transferring to `address(0)` while the others won't. There's a concrete counterexample showing that
- Manually introducing a bug in any of the implementations is quickly detected by the Halmos test

### Results

```bash
$ halmos
[⠢] Compiling...
[⠑] Compiling 3 files with Solc 0.8.27
[⠃] Solc 0.8.27 finished in 1.43s
Compiler run successful with warnings:
Warning (5740): Unreachable code.
   --> lib/solmate/src/tokens/ERC20.sol:135:25:
    |
135 |                         keccak256(
    |                         ^ (Relevant source part starts here and spans across multiple lines).

Warning (5740): Unreachable code.
   --> lib/solmate/src/tokens/ERC20.sol:156:13:
    |
156 |             allowance[recoveredAddress][spender] = value;
    |             ^ (Relevant source part starts here and spans across multiple lines).


Running 1 tests for test/ERC20.t.sol:ERC20Test
[PASS] check_differential_erc20(address[]) (paths: 15657, time: 2119.80s, bounds: [senders=[2]])
Symbolic test result: 1 passed; 0 failed; time: 2120.02s
```