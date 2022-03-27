// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {ERC721PayableMintable} from "../ERC721PayableMintable.sol";
import {MockERC721PayableMintable} from "./mocks/MockERC721PayableMintable.sol";

contract ERC721PayableMintableTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    MockERC721PayableMintable token;

    uint256 constant PAYMENT = 0.001 ether;

    address constant OTHER_ADDRESS = address(1);
    address constant OWNER = address(2);
    address constant PAYMENT_RECIPIENT = address(3);
    address constant TOKEN_HOLDER = address(4);

    function setUp() public {
        vm.prank(OWNER);
        token = new MockERC721PayableMintable();
    }

    function testMetadata() public {
        assertEq(token.name(), token.NAME());
        assertEq(token.symbol(), token.SYMBOL());
    }

    /// Mint

    function testMint(uint96 amount) public {
        vm.assume(amount >= PAYMENT);
        token.mint{value: amount}();

        assertEq(address(token).balance, amount);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.ownerOf(0), address(this));

        assertEq(token.ownerOf(1), address(0));
    }

    function testMintWithInsufficientPayment(uint96 amount) public {
        vm.assume(amount < PAYMENT);

        vm.expectRevert(ERC721PayableMintable.InsufficientPayment.selector);
        token.mint{value: amount}();

        assertEq(address(token).balance, 0 ether);

        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.ownerOf(0), address(0));
    }

    function testMintWithinCap() public {
        for (uint256 index = 0; index < token.supplyCap(); index++) {
            token.mint{value: PAYMENT}();
        }

        assertEq(token.totalSupply(), token.supplyCap());
        assertEq(token.balanceOf(address(this)), token.supplyCap());
        assertEq(token.ownerOf(token.supplyCap()), address(0));
    }

    function testMintOverCap() public {
        for (uint256 index = 0; index < token.supplyCap(); index++) {
            token.mint{value: PAYMENT}();
        }

        vm.expectRevert(ERC721PayableMintable.SupplyCapReached.selector);
        token.mint{value: PAYMENT}();

        assertEq(token.totalSupply(), token.supplyCap());
        assertEq(token.balanceOf(address(this)), token.supplyCap());
        assertEq(token.ownerOf(token.supplyCap()), address(0));
    }

    function testOwnerMint() public {
        vm.prank(OWNER);
        token.ownerMint();

        assertEq(token.totalSupply(), token.ownerAllocation());
        assertEq(token.ownerOf(0), OWNER);
        assertEq(token.balanceOf(OWNER), token.ownerAllocation());
        assertEq(token.ownerOf(token.ownerAllocation()), address(0));
    }

    function testOwnerMintWhenNotOwner() public {
        vm.prank(OTHER_ADDRESS);
        vm.expectRevert("Ownable: caller is not the owner");
        token.ownerMint();

        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(address(OTHER_ADDRESS)), 0);
        assertEq(token.ownerOf(0), address(0));
    }

    function testOwnerMintWhenOwnerAlreadyMinted() public {
        vm.prank(OWNER);
        token.ownerMint();

        vm.prank(OWNER);
        vm.expectRevert(ERC721PayableMintable.OwnerAlreadyMinted.selector);
        token.ownerMint();

        assertEq(token.totalSupply(), token.ownerAllocation());
        assertEq(token.balanceOf(address(OWNER)), token.ownerAllocation());
        assertEq(token.ownerOf(token.ownerAllocation()), address(0));
    }

    function testOwnerMintNearCap() public {
        for (uint256 index = 0; index < token.supplyCap() - 1; index++) {
            token.mint{value: PAYMENT}();
        }

        vm.prank(OWNER);
        token.ownerMint();

        assertEq(token.ownerOf(token.totalSupply() - 1), OWNER);
        assertEq(token.totalSupply(), token.supplyCap());
        assertEq(token.balanceOf(address(this)), token.supplyCap() - 1);
        assertEq(token.ownerOf(token.supplyCap()), address(0));
    }

    /// Payment

    function testWithdraw(uint96 amount) public {
        vm.assume(amount >= PAYMENT);
        token.mint{value: amount}();

        vm.prank(OWNER);
        token.withdraw(PAYMENT_RECIPIENT);

        assertEq(address(PAYMENT_RECIPIENT).balance, amount);
    }

    function testWithdrawWhenNotOwner(uint96 amount) public {
        vm.assume(amount >= PAYMENT);
        token.mint{value: amount}();

        vm.prank(OTHER_ADDRESS);
        vm.expectRevert("Ownable: caller is not the owner");
        token.withdraw(OTHER_ADDRESS);

        assertEq(address(token).balance, amount);
        assertEq(address(OTHER_ADDRESS).balance, 0 ether);
    }
}
