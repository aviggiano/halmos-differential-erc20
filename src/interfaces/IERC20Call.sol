// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20Call {
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}
