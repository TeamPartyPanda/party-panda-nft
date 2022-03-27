// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {ERC721PayableMintable} from "../ERC721PayableMintable.sol";
import {MockERC721PayableMintableComposableSVG} from "./mocks/MockERC721PayableMintableComposableSVG.sol";
import {WaveBackground} from "../WaveBackground.sol";

contract WaveBackgroundTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    WaveBackground token;

    uint256 constant PAYMENT = 0 ether;

    address constant OTHER_ADDRESS = address(1);
    address constant OWNER = address(2);
    address constant PAYMENT_RECIPIENT = address(3);
    address constant TOKEN_HOLDER = address(4);

    string constant TOKEN_NAME = "Token Name";

    string constant NAME = "Wave Background";
    string constant SYMBOL = "WAVE";

    int256 Z_INDEX = -100;

    function setUp() public {
        vm.prank(OWNER);
        token = new WaveBackground();
    }

    function testMetadata() public {
        assertEq(token.name(), NAME);
        assertEq(token.symbol(), SYMBOL);
        assertEq(token.zIndex(), Z_INDEX);
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

    /// Compose
    function testAdd() public {
        token.mint{value: PAYMENT}();

        MockERC721PayableMintableComposableSVG composable = new MockERC721PayableMintableComposableSVG();
        composable.mint{value: 0.001 ether}();

        token.addToComposable(0, address(composable), 0);

        assertEq(token.ownerOf(0), address(composable));
        assertEq(composable.backgroundName(0), NAME);
    }

    function testRemove() public {
        payable(TOKEN_HOLDER).transfer(1 ether);

        vm.prank(TOKEN_HOLDER);
        token.mint{value: PAYMENT}();

        MockERC721PayableMintableComposableSVG composable = new MockERC721PayableMintableComposableSVG();

        vm.prank(TOKEN_HOLDER);
        composable.mint{value: 0.001 ether}();

        vm.prank(TOKEN_HOLDER);
        token.addToComposable(0, address(composable), 0);

        vm.prank(TOKEN_HOLDER);
        composable.removeComposable(0, address(token), 0);

        assertEq(token.ownerOf(0), TOKEN_HOLDER);
        assertEq(composable.backgroundName(0), "");
    }
}
