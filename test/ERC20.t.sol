// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {ERC20OpenZeppelin} from "@src/ERC20OpenZeppelin.sol";
import {ERC20Solady} from "@src/ERC20Solady.sol";
import {ERC20Solmate} from "@src/ERC20Solmate.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

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
            IERC20.balanceOf.selector,
            IERC20.allowance.selector,
            IERC20.name.selector,
            IERC20.symbol.selector,
            IERC20.decimals.selector,
            IERC20.totalSupply.selector
        ];

        callSelectors = [
            IERC20.transfer.selector,
            IERC20.approve.selector,
            IERC20.transferFrom.selector,
            MockERC20.burn.selector,
            MockERC20.mint.selector
        ];
    }

    function test_differential_erc20(address[] memory senders, bytes memory call, bytes memory staticcall) public {
        for (uint256 i = 0; i < senders.length; i++) {
            vm.assume(senders[i] != address(0));
        }
        address[3] memory contracts = [address(openzeppelin), address(solady), address(solmate)];

        bytes memory result;

        for (uint256 j = 0; j < senders.length; j++) {
            for (uint256 i = 0; i < contracts.length; i++) {
                vm.prank(senders[j]);
                (bool _success, bytes memory _result) = contracts[i].call(call);
                vm.assume(_success);
                if (i == 0) {
                    result = _result;
                } else {
                    assertEq(result, _result);
                }
            }
        }

        for (uint256 i = 0; i < contracts.length; i++) {
            (bool _success, bytes memory _result) = contracts[i].staticcall(staticcall);
            vm.assume(_success);
            if (i == 0) {
                result = _result;
            } else {
                assertEq(result, _result);
            }
        }
    }

    function check_differential_erc20(address[] memory senders) public {
        bytes memory call = svm.createCalldata("MockERC20");
        bytes memory staticcall = svm.createCalldata("MockERC20", true);
        test_differential_erc20(senders, call, staticcall);
    }

    function test_differential_erc20_concrete() public {
        uint256 p_amount_uint256_21 = 0;
        address p_from_address_19 = 0x7fFFfFfFFFfFFFFfFffFfFfFfffFFfFfFffFFFFf;
        address p_to_address_20 = 0x2000000000000000000000000000000000000000;

        address[] memory p_senders = new address[](2);
        p_senders[0] = 0x2000000000000000000000000000000000000000;
        p_senders[1] = 0x4000000000000000000000000000000000000000;

        bytes memory call =
            abi.encodeCall(IERC20.transferFrom, (p_from_address_19, p_to_address_20, p_amount_uint256_21));

        return test_differential_erc20(p_senders, call, "");
    }
}
