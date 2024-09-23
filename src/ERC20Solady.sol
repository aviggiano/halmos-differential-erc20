// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@solady/tokens/ERC20.sol";

contract ERC20Solady is ERC20 {
    string internal name_;
    string internal symbol_;
    uint8 internal decimals_;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, address owner, uint256 supply) {
        name_ = _name;
        symbol_ = _symbol;
        decimals_ = _decimals;

        _mint(owner, supply);
    }

    function name() public view virtual override returns (string memory) {
        return name_;
    }

    function symbol() public view virtual override returns (string memory) {
        return symbol_;
    }

    function decimals() public view virtual override returns (uint8) {
        return decimals_;
    }

    function nonces(address) public view virtual override returns (uint256) {
        return 0;
    }

    function permit(address, address, uint256, uint256, uint8, bytes32, bytes32) public virtual override {
        revert();
    }

    function DOMAIN_SEPARATOR() public view virtual override returns (bytes32) {
        revert();
    }
}
