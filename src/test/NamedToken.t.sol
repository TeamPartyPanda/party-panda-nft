// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {MockNamedToken} from "./mocks/MockNamedToken.sol";
import {NamedToken} from "../NamedToken.sol";

contract NamedTokenTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    MockNamedToken token;

    address constant OTHER_ADDRESS = address(1);
    address constant OWNER = address(2);
    address constant PAYMENT_RECIPIENT = address(3);
    address constant TOKEN_HOLDER = address(4);

    string constant TOKEN_NAME = "Token Name";

    function setUp() public {
        vm.prank(OWNER);
        token = new MockNamedToken();
    }

    function testTokenName(uint256 tokenId) public {
        assertEq(
            token.tokenName(tokenId),
            string.concat("Mock NamedToken #", Strings.toString(tokenId))
        );
    }

    function testChangeTokenName(uint256 tokenId) public {
        token.changeTokenName(tokenId, TOKEN_NAME);

        assertEq(token.tokenName(tokenId), TOKEN_NAME);
    }

    function testChangeTokenNameInvalidTokenName(
        uint256 tokenId,
        string memory tokenName
    ) public {
        vm.assume(!token.validateTokenName(tokenName));
        vm.expectRevert(NamedToken.InvalidTokenName.selector);
        token.changeTokenName(tokenId, tokenName);

        assertEq(
            token.tokenName(tokenId),
            string.concat("Mock NamedToken #", Strings.toString(tokenId))
        );
    }

    function testValidateTokenNameEmptyString() public {
        assertTrue(!token.validateTokenName(""));
    }

    function testValidateTokenNameSpecialCharacters() public {
        assertTrue(!token.validateTokenName("-"));
    }

    function testValidateTokenNameLeadingSpace() public {
        assertTrue(!token.validateTokenName(string.concat(" ", TOKEN_NAME)));
    }

    function testValidateTokenNameTrailingSpace() public {
        assertTrue(!token.validateTokenName(string.concat(TOKEN_NAME, " ")));
    }

    function testValidateTokenNameMultipleSpaces() public {
        assertTrue(
            !token.validateTokenName(
                string.concat(TOKEN_NAME, "  ", TOKEN_NAME)
            )
        );
    }

    function testValidateTokenNameTooLong() public {
        assertTrue(!token.validateTokenName("01234567890123456789012345"));
    }
}
