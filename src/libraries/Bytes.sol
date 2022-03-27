// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;

// From: https://github.com/scaffold-eth/scaffold-eth/blob/loogies-svg-nft/packages/hardhat/contracts/ToColor.sol
library Bytes {
    error ToUint256OutOfBounds();

    // https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol#L374
    function toUint256(bytes memory _bytes) internal pure returns (uint256) {
        if (_bytes.length < 32) revert ToUint256OutOfBounds();
        uint256 tempUint;

        assembly {
            tempUint := mload(add(_bytes, 0x20))
        }

        return tempUint;
    }
}
