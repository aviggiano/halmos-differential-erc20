// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {ERC20OpenZeppelin} from "@src/ERC20OpenZeppelin.sol";
import {ERC20Solady} from "@src/ERC20Solady.sol";
import {ERC20Solmate} from "@src/ERC20Solmate.sol";

contract ERC20Test is Test, SymTest {
    ERC20OpenZeppelin public openzeppelin;
    ERC20Solady public solady;
    ERC20Solmate public solmate;

    function setUp() public {
        openzeppelin = new ERC20OpenZeppelin("Token", "TOK", 6, msg.sender, 123e18);
        solady = new ERC20Solady("Token", "TOK", 6, msg.sender, 123e18);
        solmate = new ERC20Solmate("Token", "TOK", 6, msg.sender, 123e18);
    }

    function check_differential_staticcall(bytes memory data) public view {
        address[3] memory contracts = [address(openzeppelin), address(solady), address(solmate)];
        bool success;
        bytes memory result;
        for (uint256 i = 0; i < contracts.length; i++) {
            (bool _success, bytes memory _result) = contracts[i].staticcall(data);
            if (i == 0) {
                success = _success;
                result = _result;
            } else {
                assertEq(success, _success);
                assertEq(result, _result);
            }
        }
    }

    function check_differential_call(bytes[] memory call, bytes[] memory staticcall) public {
        address[3] memory contracts = [address(openzeppelin), address(solady), address(solmate)];
        bool success;
        bytes memory result;
        for (uint256 i = 0; i < contracts.length; i++) {
            (bool _success, bytes memory _result) = contracts[i].call(call[i]);
            if (i == 0) {
                success = _success;
                result = _result;
            } else {
                assertEq(success, _success);
                assertEq(result, _result);
            }
        }
        for (uint256 i = 0; i < staticcall.length; i++) {
            (bool _success, bytes memory _result) = contracts[i].staticcall(staticcall[i]);
            if (i == 0) {
                success = _success;
                result = _result;
            } else {
                assertEq(success, _success);
                assertEq(result, _result);
            }
        }
    }
}
