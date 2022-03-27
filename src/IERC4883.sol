// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC4883 is IERC165 {
    function zIndex() external view returns (int256);

    function render(uint256 tokenId) external view returns (string memory);
}
