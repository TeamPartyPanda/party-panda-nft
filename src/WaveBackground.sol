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

contract WaveBackground is ERC721PayableMintable, IERC4883 {
    using Colours for bytes3;

    mapping(uint256 => bytes3) private _colours;

    int256 public immutable zIndex;

    constructor() ERC721PayableMintable("Wave Background", "WAVE", 0 ether, 42, 42) {
        zIndex = -100;
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
        string memory description = "Wave. Background for Party Panda NFTs";

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
            "wave",
            Strings.toString(tokenId),
            '" width="288" height="288" viewBox="0 0 288 288" fill="none" xmlns="http://www.w3.org/2000/svg">',
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
                '<g id="wave">'
                '<g transform="translate(144,144) scale(1,1) translate(-144,-144)"><linearGradient id="lg-0.0007576276008076643" x1="0" x2="1" y1="0" y2="0">'
                '<stop stop-color="#ff00ff" offset="0"></stop>'
                '<stop stop-color="#00ffff" offset="1"></stop>'
                '</linearGradient><path d="" fill="url(#lg-0.0007576276008076643)" opacity="0.4">'
                '<animate attributeName="d" dur="10s" repeatCount="indefinite" keyTimes="0;0.333;0.667;1" calcmod="spline" keySplines="0.2 0 0.2 1;0.2 0 0.2 1;0.2 0 0.2 1" begin="0s" values="M0 0L 0 249.3478160469087Q 28.8 271.20875796797964  57.6 243.19677845047337T 115.2 220.84783850028492T 172.8 190.67319530444155T 230.4 198.70816949285725T 288 177.7854552220291L 288 0 Z;M0 0L 0 244.01646850408764Q 28.8 258.5770569600993  57.6 228.0001947903528T 115.2 240.18036668638092T 172.8 207.11316893376122T 230.4 204.29282283007936T 288 189.51717085666166L 288 0 Z;M0 0L 0 282.5531364453796Q 28.8 261.8044198477804  57.6 224.14288991057037T 115.2 217.13703938710012T 172.8 194.86879702206704T 230.4 198.2381575000438T 288 166.99020553361333L 288 0 Z;M0 0L 0 249.3478160469087Q 28.8 271.20875796797964  57.6 243.19677845047337T 115.2 220.84783850028492T 172.8 190.67319530444155T 230.4 198.70816949285725T 288 177.7854552220291L 288 0 Z"></animate>'
                '</path><path d="" fill="url(#lg-0.0007576276008076643)" opacity="0.4">'
                '<animate attributeName="d" dur="10s" repeatCount="indefinite" keyTimes="0;0.333;0.667;1" calcmod="spline" keySplines="0.2 0 0.2 1;0.2 0 0.2 1;0.2 0 0.2 1" begin="-3.3333333333333335s" values="M0 0L 0 241.91399976511337Q 28.8 272.773031824481  57.6 221.6330991204484T 115.2 203.554617966047T 172.8 215.3598833767817T 230.4 208.331215945932T 288 159.3922817012802L 288 0 Z;M0 0L 0 267.89249867026297Q 28.8 261.5378358664616  57.6 220.72516882318087T 115.2 204.88274072914487T 172.8 187.6560243398394T 230.4 167.41828303154165T 288 195.78093900615812L 288 0 Z;M0 0L 0 252.82333411101428Q 28.8 293.3915055414478  57.6 252.16446051277478T 115.2 201.5700091585775T 172.8 201.7484716305146T 230.4 202.12263583758465T 288 173.66216218576926L 288 0 Z;M0 0L 0 241.91399976511337Q 28.8 272.773031824481  57.6 221.6330991204484T 115.2 203.554617966047T 172.8 215.3598833767817T 230.4 208.331215945932T 288 159.3922817012802L 288 0 Z"></animate>'
                '</path><path d="" fill="url(#lg-0.0007576276008076643)" opacity="0.4">'
                '<animate attributeName="d" dur="10s" repeatCount="indefinite" keyTimes="0;0.333;0.667;1" calcmod="spline" keySplines="0.2 0 0.2 1;0.2 0 0.2 1;0.2 0 0.2 1" begin="-6.666666666666667s" values="M0 0L 0 263.26462729185835Q 28.8 291.59686587726713  57.6 255.90098957857725T 115.2 228.43886085937962T 172.8 212.01054854726448T 230.4 187.10076529478778T 288 161.9028458031765L 288 0 Z;M0 0L 0 239.01027845858462Q 28.8 265.0748050205812  57.6 234.1974008014628T 115.2 210.2224266016108T 172.8 221.36373409559496T 230.4 202.0501911637237T 288 179.7894671663367L 288 0 Z;M0 0L 0 265.45535094365033Q 28.8 248.27083050546915  57.6 218.6680765245456T 115.2 217.29793880408266T 172.8 187.19331156562936T 230.4 195.84859895912288T 288 151.99493293483093L 288 0 Z;M0 0L 0 263.26462729185835Q 28.8 291.59686587726713  57.6 255.90098957857725T 115.2 228.43886085937962T 172.8 212.01054854726448T 230.4 187.10076529478778T 288 161.9028458031765L 288 0 Z"></animate>'
                '</path></g>'
                '</g>'
            );
    }

    function addToComposable(uint256 tokenId, address composableToken, uint256 composableTokenId) external {
        safeTransferFrom(msg.sender, composableToken, tokenId, abi.encode(composableTokenId));
    }
}
