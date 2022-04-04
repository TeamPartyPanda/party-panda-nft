// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC4883 is IERC165 {
    // Optional
    function zIndex() external view returns (int256);

    function width() external view returns (uint256);
    function height() external view returns (uint256);

    function renderTokenById(uint256 id) external view returns (string memory);
}
