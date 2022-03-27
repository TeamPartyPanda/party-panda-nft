// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {Colours} from "./libraries/Colours.sol";
import {Bytes} from "./libraries/Bytes.sol";
import {IERC4883} from "./IERC4883.sol";
import {ERC721PayableMintable} from "./ERC721PayableMintable.sol";

contract PandaNounsGlasses is ERC721PayableMintable, IERC4883 {
    using Colours for bytes3;

    /// ERRORS

    /// EVENTS

    mapping(uint256 => bytes3) private _colours;

    int256 public immutable zIndex;

    constructor()
        ERC721PayableMintable("Panda Nouns Glasses", "PNG", 0.00009999 ether, 99, 9999)
    {
        zIndex = 100;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        override(ERC721, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC4883).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _mint() internal override {
        uint256 tokenId = totalSupply;

        // from: https://github.com/scaffold-eth/scaffold-eth/blob/48be9829d9c925e4b4cda8735ddc9ff0675d9751/packages/hardhat/contracts/YourCollectible.sol
        bytes32 predictableRandom = keccak256(
            abi.encodePacked(
                tokenId,
                blockhash(block.number),
                msg.sender,
                address(this)
            )
        );
        _colours[tokenId] =
            bytes2(predictableRandom[0]) |
            (bytes2(predictableRandom[1]) >> 8) |
            (bytes3(predictableRandom[2]) >> 16);

        super._mint();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert NonexistentToken();

        string memory tokenName_ = string.concat(
            name,
            " #",
            Strings.toString(tokenId)
        );
        string memory description = "Panda Nouns style glasses. Inspired by Nouns public domain glasses artwork.";

        string memory image = _generateBase64Image(tokenId);
        string memory attributes = _generateAttributes(tokenId);
        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            tokenName_,
                            '", "description":"',
                            description,
                            '", "image": "data:image/svg+xml;base64,',
                            image,
                            '",',
                            attributes,
                            "}"
                        )
                    )
                )
            );
    }

    function _generateAttributes(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        //TODO get name of accessory and background

        string memory attributes = string.concat(
            '{"trait_type": "colour", "value": "',
            _colours[tokenId].toColour(),
            '"}'
        );

        return string.concat('"attributes": [', attributes, "]");
    }

    function _generateBase64Image(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        return Base64.encode(bytes(_generateSVG(tokenId)));
    }

    function _generateSVG(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        string memory svg = string.concat(
            '<svg id="',
            "nounsglasses",
            Strings.toString(tokenId),
            '" viewBox="0 0 288 288" xmlns="http://www.w3.org/2000/svg">',
            render(tokenId),
            "</svg>"
        );

        return svg;
    }

    function render(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory colourValue = string.concat(
            "#",
            _colours[tokenId].toColour()
        );

        return
            string.concat(
                '<g id="nounsglasses">'
                '<path stroke="',
                colourValue,
                '" stroke-width="5" d="M144.5 89.5h25v25h-25zm-50 22.5v-10M92 99.5h50m-32.5-10h25v25h-25z"/>'
                '<path fill="black" d="M122 92h10v20h-10z"/>'
                '<path fill="black" d="M157 92h10v20h-10z"/>'
                '<path fill="white" d="M112 92h10v20h-10z"/>'
                '<path fill="white" d="M147 92h10v20h-10z"/>'
                '</g>'
            );
    }

    function addToComposable(uint256 tokenId, address composableToken, uint256 composableTokenId) external {
        safeTransferFrom(msg.sender, composableToken, tokenId, abi.encode(composableTokenId));
    }
}
