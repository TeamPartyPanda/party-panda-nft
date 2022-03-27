// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Colours} from "./libraries/Colours.sol";
import {Bytes} from "./libraries/Bytes.sol";
import {IERC4883} from "./IERC4883.sol";
import {ERC721PayableMintableComposableSVG} from "./ERC721PayableMintableComposableSVG.sol";
import {NamedToken} from "./NamedToken.sol";

contract PartyPanda is ERC721PayableMintableComposableSVG, NamedToken {
    using Colours for bytes3;

    /// ERRORS

    /// EVENTS

    mapping(uint256 => bytes3) private _colours;

    string constant NAME = "Party Panda";

    constructor()
        ERC721PayableMintableComposableSVG(NAME, "PRTY", 0.000888 ether, 88, 888, 0)
        NamedToken(NAME)
    {}

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

        string memory tokenName_ = tokenName(tokenId);
        string
            memory description = "Party Panda NFT.";

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

    function _generatePartyValue(uint256 tokenId)
        internal
        pure
        returns (string memory)
    {
        return Strings.toString(((tokenId % 23) + 7) / 3);
    }

    function _generateAttributes(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        string memory attributes = string.concat(
            '{"trait_type": "party", "value": "',
            _generatePartyValue(tokenId),
            '"}'
            ',{"trait_type": "colour", "value": "',
            _colours[tokenId].toColour(),
            '"}'
            ',{"trait_type": "background", "value": "',
            _backgroundName(tokenId),
            '"}'
            ',{"trait_type": "foreground", "value": "',
            _foregroundName(tokenId),
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
            "panda",
            Strings.toString(tokenId),
            '" width="288" height="288" viewBox="0 0 288 288" fill="none" xmlns="http://www.w3.org/2000/svg">',
            render(tokenId),
            "</svg>"
        );

        return svg;
    }

    function _renderBody(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        string memory colourValue = string.concat(
            "#",
            _colours[tokenId].toColour()
        );

        return
            string.concat(
                '<g id="panda">'
                '<!--Copyright 2022 Alex Party Panda https://github.com/AlexPartyPanda-->'
                '<path d="M97.5 183.5c-22.878-11.248-31.543-10.843-37 6 1.297 16.917 3.99 21.712 11 25 10.177 4.886 38.421-1.909 71-6.5 45.864 5.702 75.701 9.828 81.5 6.5 8.506-5.407 11.972-9.787 11-25-8.153-11.761-13.16-16.601-26-9.5l-16-8.5-95.5 12Z" fill="',colourValue, '" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
                '<path d="m115 205.5-4.5-41h57v45c-16.505 5.452-33.861 9.59-52.5-4Z" fill="#FFF" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
                '<path d="M124 215c-6.408 1.507-33.142 12.135-39-4 .419-11.525 1.364-21.559 3.647-31.5 3.406-14.829 9.792-29.45 21.853-48.5 27.727 17.26 40.773 13.3 68.5.5 12.01 17.087 19.173 31.974 19.093 44.5-.027 4.215 1.002 8.615 0 13.5 0 0-1.593 9.5-1.593 21.5s-32.5 15.5-36 0-1.276-7.912 3.5-35c-14.577-2.983-24.32-2.712-43.5 0 2.845 4.885 9.908 37.493 3.5 39Zm36.5-143.5c18.121-8.994 17.214-.228 16.5 20.5l-16.5-20.5Zm-52.5 14c-2.876-17.522 1.048-21.717 18-16.5l-18 16.5Z" fill="',colourValue, '" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
                '<path d="M177 92c-17.5-35.5-52-35.5-70.5-3-8.666 23.757-9.202 33.968 4 42 27.357 18.75 41.337 16.44 69 0 3.5-5.5 6.499-24.919-2.5-39Z" fill="#FFF" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
                '<path d="M131.5 125.5c9.101 3.874 10.24 3.497 18 0" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
                '<path d="M129 111.5c4.5-4.5 17-2.5 19 1-5 5-14 4-19-1ZM125 87c5.099 5.584 2.743 5.485 4.5 9-4.985.625-8.844 3.99-17.5 15-1.172-3.319-1.471-3.485-3-8.5-1.529-5.014 10.901-21.084 16-15.5Z" fill="',colourValue, '" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
                '<circle cx="119" cy="98" r="4" fill="#000"/>'
                '<path d="M162.5 85c-6.664 2.996-9.447 5.477-12.5 11.5 8.04 4.452 12.128 8.376 18.5 18.5l5.5-7.5c-2.463-11.46-4.46-17.073-11.5-22.5Z" fill="',colourValue, '" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
                '<circle cx="159" cy="99" r="4" fill="#000"/>'
                '</g>'
            );
    }

    function render(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            string.concat(
                _renderBackground(tokenId),
                _renderBody(tokenId),
                _renderForeground(tokenId)
            );
    }

    // Based on The HashMarks
    // https://etherscan.io/address/0xc2c747e0f7004f9e8817db2ca4997657a7746928#code#F7#L311
    function changeTokenName(uint256 tokenId, string memory newTokenName)
        external
    {
        if (!_exists(tokenId)) revert NonexistentToken();
        if (_msgSender() != ownerOf[tokenId]) revert NotTokenOwner();

        _changeTokenName(tokenId, newTokenName);
    }
}
