// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@solmate/tokens/ERC20.sol";

contract ERC20Solmate is ERC20 {
    constructor(string memory _name, string memory _symbol, uint8 _decimals, address owner, uint256 supply)
        ERC20(_name, _symbol, _decimals)
    {
        _mint(owner, supply);
    }

    function permit(address, address, uint256, uint256, uint8, bytes32, bytes32) public virtual override {
        revert();
    }

    function DOMAIN_SEPARATOR() public view virtual override returns (bytes32) {
        revert();
    }
}
