// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

contract MerkleTreeLeafChecker {
    /**
     * @notice Allows caller to verify the pre-image of a BoringVault Merkle Leaf.
     * @param signature the function signature
     * @param decoderAndSanitizer the address of the decoder and sanitizer
     * @param target the address of the target
     * @param canSendValue a bool indicating whether or not the call can be made with value
     * @param sensitiveArguments an array of sensitive arguments passed into the calls call data
     */
    function checkLeaf(
        string calldata signature,
        address decoderAndSanitizer,
        address target,
        bool canSendValue,
        address[] calldata sensitiveArguments
    ) external pure returns (bytes32 leafHash) {
        bytes4 selector = bytes4(keccak256(abi.encodePacked(signature)));
        bytes memory rawDigest = abi.encodePacked(decoderAndSanitizer, target, canSendValue, selector);
        uint256 sensitiveArgumentsLength = sensitiveArguments.length;
        for (uint256 i; i < sensitiveArgumentsLength; ++i) {
            rawDigest = abi.encodePacked(rawDigest, sensitiveArguments[i]);
        }
        leafHash = keccak256(rawDigest);
    }
}
