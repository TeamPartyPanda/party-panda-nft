// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Bytes} from "./libraries/Bytes.sol";
import {IERC4883} from "./IERC4883.sol";
import {ERC721PayableMintable} from "./ERC721PayableMintable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

abstract contract ERC721PayableMintableComposableSVG is
    ERC721PayableMintable,
    IERC4883,
    IERC721Receiver
{
    /// ERRORS

    /// @notice Thrown when attempting to add composable token with same Z index
    error SameZIndex();

    /// @notice Thrown when attempting to add a not composable token
    error NotComposableToken();

    /// @notice Thrown when action not from token owner
    error NotTokenOwner();

    /// @notice Thrown when background already added
    error BackgroundAlreadyAdded();

    /// @notice Thrown when foreground already added
    error ForegroundAlreadyAdded();

    /// EVENTS

    /// @notice Emitted when composable token added
    event ComposableAdded(uint256 tokenId, address composableToken, uint256 composableTokenId);
    
    /// @notice Emitted when composable token removed
    event ComposableRemoved(uint256 tokenId, address composableToken, uint256 composableTokenId);

    int256 public immutable zIndex;

    struct Token {
        address tokenAddress;
        uint256 tokenId;
    }

    struct Composable {
        Token background;
        Token foreground;
    }

    mapping(uint256 => Composable) public composables;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 price_,
        uint256 ownerAllocation_,
        uint256 supplyCap_,
        int256 z
    )
        ERC721PayableMintable(
            name_,
            symbol_,
            price_,
            ownerAllocation_,
            supplyCap_
        )
    {
        zIndex = z;
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

    function _renderBackground(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        string memory background = "";

        if (composables[tokenId].background.tokenAddress != address(0)) {
            background = IERC4883(composables[tokenId].background.tokenAddress)
                .render(composables[tokenId].background.tokenId);
        }

        return background;
    }

    function _renderForeground(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        string memory foreground = "";

        if (composables[tokenId].foreground.tokenAddress != address(0)) {
            foreground = IERC4883(composables[tokenId].foreground.tokenAddress)
                .render(composables[tokenId].foreground.tokenId);
        }

        return foreground;
    }

    function _backgroundName(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        string memory background = "";

        if (composables[tokenId].background.tokenAddress != address(0)) {
            background = ERC721(composables[tokenId].background.tokenAddress)
                .name();
        }

        return background;
    }

    function _foregroundName(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        string memory foreground = "";

        if (composables[tokenId].foreground.tokenAddress != address(0)) {
            foreground = ERC721(composables[tokenId].foreground.tokenAddress)
                .name();
        }

        return foreground;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 composableTokenId,
        bytes calldata idData
    ) external returns (bytes4) {
        uint256 tokenId = Bytes.toUint256(idData);

        if (!_exists(tokenId)) revert NonexistentToken();
        if (ownerOf[tokenId] != from) revert NotTokenOwner();

        IERC4883 composableToken = IERC4883(msg.sender);
        if (!composableToken.supportsInterface(type(IERC4883).interfaceId))
            revert NotComposableToken();

        if (composableToken.zIndex() < zIndex) {
            if (composables[tokenId].background.tokenAddress != address(0))
                revert BackgroundAlreadyAdded();
            composables[tokenId].background = Token(
                msg.sender,
                composableTokenId
            );
        } else if (composableToken.zIndex() > zIndex) {
            if (composables[tokenId].foreground.tokenAddress != address(0))
                revert ForegroundAlreadyAdded();
            composables[tokenId].foreground = Token(
                msg.sender,
                composableTokenId
            );
        } else {
            revert SameZIndex();
        }

        emit ComposableAdded(tokenId, msg.sender, composableTokenId);

        return this.onERC721Received.selector;
    }

    function removeComposable(
        uint256 tokenId,
        address composableToken,
        uint256 composableTokenId
    ) external {
        if (_msgSender() != ownerOf[tokenId]) revert NotTokenOwner();

        if (
            composables[tokenId].background.tokenAddress == composableToken &&
            composables[tokenId].background.tokenId == composableTokenId
        ) {
            composables[tokenId].background = Token(address(0), 0);
        } else if (
            composables[tokenId].foreground.tokenAddress == composableToken &&
            composables[tokenId].foreground.tokenId == composableTokenId
        ) {
            composables[tokenId].foreground = Token(address(0), 0);
        }

        ERC721(composableToken).safeTransferFrom(
            address(this),
            msg.sender,
            composableTokenId
        );

        emit ComposableRemoved(tokenId, composableToken, composableTokenId);
    }
}
