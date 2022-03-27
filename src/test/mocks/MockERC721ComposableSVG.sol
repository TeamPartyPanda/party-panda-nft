// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC4883} from "../../IERC4883.sol";

contract MockERC721ComposableSVG is ERC721, IERC4883 {
    int256 public immutable zIndex;

    constructor(int256 z) ERC721("Mock Composable", "MC") {
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

    function tokenURI(uint256)
        public
        pure
        virtual
        override
        returns (string memory)
    {}

    function mint() public virtual {
        _mint(msg.sender, totalSupply);
    }

    function render(uint256 tokenId) public view returns (string memory) {
        return '<g id="mock"></g>';
    }
}
