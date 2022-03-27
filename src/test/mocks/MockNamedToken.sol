// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {NamedToken} from "../../NamedToken.sol";

contract MockNamedToken is NamedToken {
    constructor() NamedToken("Mock NamedToken") {}

    function changeTokenName(uint256 tokenId, string memory newTokenName)
        external
    {
        _changeTokenName(tokenId, newTokenName);
    }
}
