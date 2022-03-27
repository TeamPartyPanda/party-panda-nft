// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Bytes} from "./libraries/Bytes.sol";

contract NamedToken {
    /// @notice Thrown when attempting to set an invalid token name
    error InvalidTokenName();

    /// EVENTS

    /// @notice Emitted when name changed
    event TokenNameChange(uint256 indexed tokenId, string tokenName);

    mapping(uint256 => string) private _names;
    string private _name;

    constructor(string memory name_) {
        _name = name_;
    }

    function tokenName(uint256 tokenId) public view returns (string memory) {
        string memory tokenName_ = _names[tokenId];

        bytes memory b = bytes(tokenName_);
        if (b.length < 1) {
            tokenName_ = string.concat(_name, " #", Strings.toString(tokenId));
        }

        return tokenName_;
    }

    // Based on The HashMarks
    // https://etherscan.io/address/0xc2c747e0f7004f9e8817db2ca4997657a7746928#code#F7#L311
    function _changeTokenName(uint256 tokenId, string memory newTokenName)
        internal
    {
        //if (!_exists(tokenId)) revert NonexistentToken();
        //if (_msgSender() != ownerOf[tokenId]) revert NotTokenOwner();
        if (!validateTokenName(newTokenName)) revert InvalidTokenName();

        _names[tokenId] = newTokenName;

        emit TokenNameChange(tokenId, newTokenName);
    }

    // From The HashMarks
    // https://etherscan.io/address/0xc2c747e0f7004f9e8817db2ca4997657a7746928#code#F7#L612
    function validateTokenName(string memory str) public pure returns (bool) {
        bytes memory b = bytes(str);
        if (b.length < 1) return false;
        if (b.length > 25) return false; // Cannot be longer than 25 characters
        if (b[0] == 0x20) return false; // Leading space
        if (b[b.length - 1] == 0x20) return false; // Trailing space

        bytes1 lastChar = b[0];

        for (uint i; i < b.length; i++) {
            bytes1 char = b[i];

            if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces

            if (
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A) && //A-Z
                !(char >= 0x61 && char <= 0x7A) && //a-z
                !(char == 0x20) //space
            ) return false;

            lastChar = char;
        }

        return true;
    }
}
