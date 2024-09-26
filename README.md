## halmos-differential-erc20

Halmos Differential Tests for Common ERC-20 Token Implementations

### Description

This test uses N `msg.senders` to execute N arbitrary calls (using the new `createCalldata` cheatcode) and 1 arbitrary staticcall to see if the view functions return the same thing after changing the state

### Notes

- Error messages won't be the same, so checking for call success & return value does not work if the call fails
- OpenZeppelin will revert when transferring to `address(0)` while the others won't. There's a concrete counterexample showing that
- Manually introducing a bug in any of the implementations is quickly detected by the Halmos test
