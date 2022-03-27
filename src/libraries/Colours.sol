// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// From: https://github.com/scaffold-eth/scaffold-eth/blob/loogies-svg-nft/packages/hardhat/contracts/ToColor.sol
library Colours {
    bytes16 internal constant ALPHABET = "0123456789abcdef";

    function toColour(bytes3 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 0; i < 3; i++) {
            buffer[i * 2 + 1] = ALPHABET[uint8(value[i]) & 0xf];
            buffer[i * 2] = ALPHABET[uint8(value[i] >> 4) & 0xf];
        }
        return string(buffer);
    }
}
