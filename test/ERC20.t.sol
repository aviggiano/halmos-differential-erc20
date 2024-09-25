// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
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

    function check_differential_erc20(address[] memory senders, uint256 n_staticcalls) public {
        vm.assume(n_staticcalls <= staticcallSelectors.length);

        address[3] memory contracts = [address(openzeppelin), address(solady), address(solmate)];

        bytes[] memory results;

        results = new bytes[](senders.length);
        for (uint256 j = 0; j < senders.length; j++) {
            for (uint256 i = 0; i < contracts.length; i++) {
                bytes memory call = svm.createCalldata("MockERC20");
                vm.prank(senders[j]);
                (bool _success, bytes memory _result) = contracts[i].call(call);
                vm.assume(_success);
                if (i == 0) {
                    results[i] = _result;
                } else {
                    assertEq(results[i], _result);
                }
            }
        }

        results = new bytes[](n_staticcalls);
        for (uint256 j = 0; j < n_staticcalls; j++) {
            for (uint256 i = 0; i < contracts.length; i++) {
                bytes memory staticcall = svm.createCalldata("MockERC20", true);
                (bool _success, bytes memory _result) = contracts[i].staticcall(staticcall);
                vm.assume(_success);
                if (i == 0) {
                    results[i] = _result;
                } else {
                    assertEq(results[i], _result);
                }
            }
        }
    }
}
