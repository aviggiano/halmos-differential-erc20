// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {ERC20OpenZeppelin} from "@src/ERC20OpenZeppelin.sol";
import {ERC20Solady} from "@src/ERC20Solady.sol";
import {ERC20Solmate} from "@src/ERC20Solmate.sol";
import {IERC20Call} from "@src/interfaces/IERC20Call.sol";
import {IERC20Staticcall} from "@src/interfaces/IERC20Staticcall.sol";

/// @custom:halmos --storage-layout=generic --array-lengths senders=2 --loop 256
contract ERC20Test is Test, SymTest {
    ERC20OpenZeppelin public openzeppelin;
    ERC20Solady public solady;
    ERC20Solmate public solmate;

    bytes4[] staticcallSelectors;
    bytes4[] callSelectors;

    function setUp() public {
        openzeppelin = new ERC20OpenZeppelin("Token", "TOK", 6);
        solady = new ERC20Solady("Token", "TOK", 6);
        solmate = new ERC20Solmate("Token", "TOK", 6);

        staticcallSelectors = [
            IERC20Staticcall.balanceOf.selector,
            IERC20Staticcall.allowance.selector,
            IERC20Staticcall.name.selector,
            IERC20Staticcall.symbol.selector,
            IERC20Staticcall.decimals.selector,
            IERC20Staticcall.totalSupply.selector
        ];

        callSelectors = [
            IERC20Call.transfer.selector,
            IERC20Call.approve.selector,
            IERC20Call.transferFrom.selector,
            IERC20Call.burn.selector,
            IERC20Call.mint.selector
        ];
    }

    function test_differential_erc20(
        address[] memory senders,
        bytes[] memory calls,
        bytes memory staticcall,
        bool shouldCheckFailedCall
    ) public {
        vm.assume(senders.length == calls.length);
        for (uint256 i = 0; i < senders.length; i++) {
            vm.assume(senders[i] != address(0));
        }
        address[3] memory contracts = [address(openzeppelin), address(solady), address(solmate)];

        bool success;
        bytes memory result;

        for (uint256 j = 0; j < calls.length; j++) {
            for (uint256 i = 0; i < contracts.length; i++) {
                vm.prank(senders[j]);
                (bool _success, bytes memory _result) = contracts[i].call(calls[j]);
                if (!shouldCheckFailedCall) {
                    vm.assume(_success);
                }
                if (i == 0) {
                    result = _result;
                    success = _success;
                } else {
                    if (success != _success || keccak256(result) != keccak256(_result)) {
                        console.logBytes(calls[j]);
                        console.logBool(success);
                        console.logBool(_success);
                        console.logBytes(result);
                        console.logBytes(_result);
                        console.log("");
                    }
                    assertEq(success, _success);
                    if (success) {
                        assertEq(result, _result);
                    }
                }
            }
        }

        for (uint256 i = 0; i < contracts.length; i++) {
            (bool _success, bytes memory _result) = contracts[i].staticcall(staticcall);
            if (i == 0) {
                result = _result;
                success = success;
            } else {
                assertEq(success, _success);
                if (success) {
                    assertEq(result, _result);
                }
            }
        }
    }

    function check_differential_erc20(address[] memory senders) public {
        bytes[] memory calls = new bytes[](senders.length);
        for (uint256 i = 0; i < senders.length; i++) {
            calls[i] = svm.createCalldata("IERC20Call");
        }
        bytes memory staticcall = svm.createCalldata("IERC20Staticcall", true);
        test_differential_erc20(senders, calls, staticcall, false);
    }

    function testFail_differential_erc20_concrete() public {
        uint256 p_amount_uint256_26 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        address p_from_address_11 = address(0x4);
        address p_from_address_24 = address(0x0000000000000000000000000000000000000000);
        address p_to_address_25 = 0x0000000000000000000000000000000000000000;

        address[] memory p_senders = new address[](2);
        p_senders[0] = 0x0000000000000000000000000000008000000000;
        p_senders[1] = 0x0000000000000000000000000000000008000000;

        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeCall(IERC20Call.transferFrom, (p_from_address_11, p_to_address_25, p_amount_uint256_26));
        calls[1] = abi.encodeCall(IERC20Call.transferFrom, (p_from_address_24, p_to_address_25, p_amount_uint256_26));

        return test_differential_erc20(p_senders, calls, "", true);
    }
}
