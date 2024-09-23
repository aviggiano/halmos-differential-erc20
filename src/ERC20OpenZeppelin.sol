// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20OpenZeppelin is ERC20 {
    uint8 private immutable decimals_ = 18;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, address owner, uint256 supply)
        ERC20(_name, _symbol)
    {
        decimals_ = _decimals;
        _mint(owner, supply);
    }

    function decimals() public pure override returns (uint8) {
        return decimals_;
    }

    function nonces(address) public pure returns (uint256) {
        return 0;
    }
}
