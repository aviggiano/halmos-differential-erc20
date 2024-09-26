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
        if (senders.length != calls.length) {
            return;
        }
        for (uint256 i = 0; i < senders.length; i++) {
            vm.assume(senders[i] != address(0));
        }

        address[3] memory contracts = [address(openzeppelin), address(solady), address(solmate)];
        bool[3] memory successes;
        bytes[3] memory results;

        for (uint256 j = 0; j < calls.length; j++) {
            for (uint256 i = 0; i < contracts.length; i++) {
                vm.prank(senders[j]);
                (bool _success, bytes memory _result) = contracts[i].call(calls[j]);
                if (!shouldCheckFailedCall) {
                    vm.assume(_success);
                }
                successes[i] = _success;
                results[i] = _result;
            }
        }

        verifyResults(successes, results);

        for (uint256 i = 0; i < contracts.length; i++) {
            (bool _success, bytes memory _result) = contracts[i].staticcall(staticcall);
            successes[i] = _success;
            results[i] = _result;
        }

        verifyResults(successes, results);
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

    function verifyResults(bool[3] memory successes, bytes[3] memory results) private pure {
        for (uint256 i = 0; i < successes.length - 1; i++) {
            // if (successes[i] != successes[i + 1]) {
            //     console.logBool(successes[i]);
            //     console.logBool(successes[i + 1]);
            //     console.logBytes(results[i]);
            //     console.logBytes(results[i + 1]);
            //     console.log("");
            // }
            assertEq(successes[i], successes[i + 1]);
            if (successes[i]) {
                // if (keccak256(results[i]) != keccak256(results[i + 1])) {
                //     console.logBool(successes[i]);
                //     console.logBool(successes[i + 1]);
                //     console.logBytes(results[i]);
                //     console.logBytes(results[i + 1]);
                //     console.log("");
                // }

                assertEq(results[i], results[i + 1]);
            }
        }
    }
}
