// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {MockERC721ComposableSVG} from "./mocks/MockERC721ComposableSVG.sol";
import {NamedToken} from "../NamedToken.sol";
import {ERC721PayableMintable} from "../ERC721PayableMintable.sol";
import {ERC721PayableMintableComposableSVG} from "../ERC721PayableMintableComposableSVG.sol";
import {PartyPanda} from "../PartyPanda.sol";

contract PartyPandaTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    PartyPanda token;

    uint256 constant PAYMENT = 0.000888 ether;

    address constant OTHER_ADDRESS = address(1);
    address constant OWNER = address(2);
    address constant PAYMENT_RECIPIENT = address(3);
    address constant TOKEN_HOLDER = address(4);

    string constant TOKEN_NAME = "Token Name";

    function setUp() public {
        vm.prank(OWNER);
        token = new PartyPanda();
    }

    function testMetadata() public {
        assertEq(token.name(), "Party Panda");
        assertEq(token.symbol(), "PRTY");
    }

    /// Mint

    function testMint(uint96 amount) public {
        vm.assume(amount >= PAYMENT);
        token.mint{value: amount}();

        assertEq(address(token).balance, amount);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.ownerOf(0), address(this));
    }

    /// Token URI

    function testTokenURI() public {
        token.mint{value: PAYMENT}();

        token.tokenURI(0);
    }

    function testTokenURINonexistentToken() public {
        vm.expectRevert(ERC721PayableMintable.NonexistentToken.selector);
        token.tokenURI(0);
    }

    /// Render

    function testRender() public {
        token.mint{value: PAYMENT}();

        emit log_string(token.render(0));
    }

    /// Token Naming

    function testTokenName() public {
        token.mint{value: PAYMENT}();

        assertEq(token.tokenName(0), "Party Panda #0");
    }

    function testChangeTokenName() public {
        token.mint{value: PAYMENT}();

        token.changeTokenName(0, TOKEN_NAME);

        assertEq(token.tokenName(0), TOKEN_NAME);
    }

    function testChangeTokenNameInvalidTokenName(string memory tokenName)
        public
    {
        vm.assume(!token.validateTokenName(tokenName));
        token.mint{value: PAYMENT}();

        vm.expectRevert(NamedToken.InvalidTokenName.selector);
        token.changeTokenName(0, tokenName);
    }

    function testChangeTokenNameNotTokenOwner() public {
        token.mint{value: PAYMENT}();

        vm.prank(OTHER_ADDRESS);
        vm.expectRevert(
            ERC721PayableMintableComposableSVG.NotTokenOwner.selector
        );
        token.changeTokenName(0, TOKEN_NAME);
    }

    function testChangeTokenNameNonexistentToken() public {
        vm.expectRevert(ERC721PayableMintable.NonexistentToken.selector);
        token.changeTokenName(0, TOKEN_NAME);
    }

    function testAddBackground(int256 zIndex) public {
        vm.assume(zIndex < 0);
        token.mint{value: PAYMENT}();

        MockERC721ComposableSVG composable = new MockERC721ComposableSVG(
            zIndex
        );
        composable.mint();

        string memory renderedToken = token.render(0);

        composable.safeTransferFrom(
            address(this),
            address(token),
            0,
            abi.encode(0)
        );

        assertTrue(
            keccak256(abi.encodePacked(token.render(0))) !=
                keccak256(abi.encodePacked(renderedToken))
        );
        assertEq(composable.ownerOf(0), address(token));
    }

    function testRemoveBackgroundToEOA() public {
        payable(TOKEN_HOLDER).transfer(1 ether);

        vm.prank(TOKEN_HOLDER);
        token.mint{value: PAYMENT}();

        MockERC721ComposableSVG composable = new MockERC721ComposableSVG(-1);
        vm.prank(TOKEN_HOLDER);
        composable.mint();

        vm.prank(TOKEN_HOLDER);
        composable.safeTransferFrom(
            address(TOKEN_HOLDER),
            address(token),
            0,
            abi.encode(0)
        );

        vm.prank(TOKEN_HOLDER);
        token.removeComposable(0, address(composable), 0);
    }

    function testAddForeground(int256 zIndex) public {
        vm.assume(zIndex > 0);
        token.mint{value: PAYMENT}();

        MockERC721ComposableSVG composable = new MockERC721ComposableSVG(
            zIndex
        );
        composable.mint();

        string memory renderedToken = token.render(0);

        composable.safeTransferFrom(
            address(this),
            address(token),
            0,
            abi.encode(0)
        );

        assertTrue(
            keccak256(abi.encodePacked(token.render(0))) !=
                keccak256(abi.encodePacked(renderedToken))
        );
        assertEq(composable.ownerOf(0), address(token));
    }

    function testRemoveForegroundToEOA() public {
        payable(TOKEN_HOLDER).transfer(1 ether);

        vm.prank(TOKEN_HOLDER);
        token.mint{value: PAYMENT}();

        MockERC721ComposableSVG composable = new MockERC721ComposableSVG(1);
        vm.prank(TOKEN_HOLDER);
        composable.mint();

        vm.prank(TOKEN_HOLDER);
        composable.safeTransferFrom(
            address(TOKEN_HOLDER),
            address(token),
            0,
            abi.encode(0)
        );

        vm.prank(TOKEN_HOLDER);
        token.removeComposable(0, address(composable), 0);
    }

    function testAddForegroundAndBackground() public {
        token.mint{value: PAYMENT}();

        string memory renderedToken = token.render(0);

        MockERC721ComposableSVG foreground = new MockERC721ComposableSVG(1);
        foreground.mint();
        foreground.safeTransferFrom(
            address(this),
            address(token),
            0,
            abi.encode(0)
        );

        MockERC721ComposableSVG background = new MockERC721ComposableSVG(-1);
        background.mint();
        background.safeTransferFrom(
            address(this),
            address(token),
            0,
            abi.encode(0)
        );

        assertTrue(
            keccak256(abi.encodePacked(token.render(0))) !=
                keccak256(abi.encodePacked(renderedToken))
        );
        assertEq(foreground.ownerOf(0), address(token));
        assertEq(background.ownerOf(0), address(token));
    }
}
