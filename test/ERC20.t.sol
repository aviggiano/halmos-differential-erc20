// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {ERC20OpenZeppelin} from "@src/ERC20OpenZeppelin.sol";
import {ERC20Solady} from "@src/ERC20Solady.sol";
import {ERC20Solmate} from "@src/ERC20Solmate.sol";

/// @custom:halmos --storage-layout=generic --array-lengths senders=3 --array-lengths calls=3 --array-lengths staticcalls=3
contract ERC20Test is Test, SymTest {
    ERC20OpenZeppelin public openzeppelin;
    ERC20Solady public solady;
    ERC20Solmate public solmate;

    bytes4[] staticcallSelectors;
    bytes4[] callSelectors;

    function setUp() public {
        openzeppelin = new ERC20OpenZeppelin("Token", "TOK", 6, address(0x1337), 123e18);
        solady = new ERC20Solady("Token", "TOK", 6, address(0x1337), 123e18);
        solmate = new ERC20Solmate("Token", "TOK", 6, address(0x1337), 123e18);

        staticcallSelectors = [
            IERC20.balanceOf.selector,
            IERC20.allowance.selector,
            IERC20.name.selector,
            IERC20.symbol.selector,
            IERC20.decimals.selector,
            IERC20.totalSupply.selector
        ];

        callSelectors = [IERC20.transfer.selector, IERC20.approve.selector, IERC20.transferFrom.selector];
    }

    function check_differential_staticcall(bytes memory data) public view {
        address[3] memory contracts = [address(openzeppelin), address(solady), address(solmate)];
        vm.assume(isValidSelector(staticcallSelectors, data));

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

    function check_differential_call(address[] memory senders, bytes[] memory calls, bytes[] memory staticcalls)
        public
    {
        vm.assume(senders.length == calls.length);
        vm.assume(isValidSelectors(callSelectors, calls));
        vm.assume(isValidSelectors(staticcallSelectors, staticcalls));

        address[3] memory contracts = [address(openzeppelin), address(solady), address(solmate)];

        bytes[] memory results;

        results = new bytes[](calls.length);
        for (uint256 j = 0; j < calls.length; j++) {
            for (uint256 i = 0; i < contracts.length; i++) {
                vm.prank(senders[j]);
                (bool _success, bytes memory _result) = contracts[i].call(calls[j]);
                vm.assume(_success);
                if (i == 0) {
                    results[i] = _result;
                } else {
                    assertEq(results[i], _result);
                }
            }
        }

        results = new bytes[](staticcalls.length);
        for (uint256 j = 0; j < staticcalls.length; j++) {
            for (uint256 i = 0; i < contracts.length; i++) {
                (bool _success, bytes memory _result) = contracts[i].staticcall(staticcalls[j]);
                vm.assume(_success);
                if (i == 0) {
                    results[i] = _result;
                } else {
                    assertEq(results[i], _result);
                }
            }
        }
    }

    function isValidSelectors(bytes4[] memory validSelectors, bytes[] memory datas)
        internal
        pure
        returns (bool valid)
    {
        for (uint256 i = 0; i < validSelectors.length; i++) {
            valid = false;
            for (uint256 j = 0; j < datas.length; j++) {
                if (bytes4(datas[j]) == validSelectors[i]) {
                    valid = true;
                    break;
                }
            }
            if (!valid) {
                break;
            }
        }
    }

    function isValidSelector(bytes4[] memory validSelectors, bytes memory data) internal pure returns (bool valid) {
        for (uint256 i = 0; i < validSelectors.length; i++) {
            if (bytes4(data) == validSelectors[i]) {
                valid = true;
                break;
            }
        }
    }
}
