// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ERC721PayableMintable is ERC721, Ownable {
    /// ERRORS

    /// @notice Thrown when underpaying
    error InsufficientPayment();

    /// @notice Thrown when owner already minted
    error OwnerAlreadyMinted();

    /// @notice Thrown when supply cap reached
    error SupplyCapReached();

    /// @notice Thrown when token doesn't exist
    error NonexistentToken();

    /// EVENTS

    bool private ownerMinted = false;

    uint256 public immutable price;
    uint256 public immutable ownerAllocation;
    uint256 public immutable supplyCap;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 price_,
        uint256 ownerAllocation_,
        uint256 supplyCap_
    ) ERC721(name_, symbol_) {
        price = price_;
        ownerAllocation = ownerAllocation_;
        supplyCap = supplyCap_;
    }

    function mint() public payable {
        if (msg.value < price) revert InsufficientPayment();
        if (totalSupply >= supplyCap) revert SupplyCapReached();
        _mint();
    }

    function ownerMint() public onlyOwner {
        if (ownerMinted) revert OwnerAlreadyMinted();

        uint256 available = ownerAllocation;
        if (totalSupply + ownerAllocation > supplyCap) {
            available = supplyCap - totalSupply;
        }

        for (uint256 index = 0; index < available;) {
            _mint();

            unchecked { ++index; }
        }

        ownerMinted = true;
    }

    function _mint() internal virtual {
        uint256 tokenId = totalSupply;
        _mint(msg.sender, tokenId);
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return ownerOf[tokenId] != address(0);
    }

    function withdraw(address to) public onlyOwner {
        payable(to).transfer(address(this).balance);
    }
}
