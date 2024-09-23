// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {MerkleTreeLeafChecker} from "src/helper/MerkleTreeLeafChecker.sol";
import {Test, stdStorage, StdStorage, stdError, console} from "@forge-std/Test.sol";

contract PauserTest is Test {
    MerkleTreeLeafChecker public checker;

    function setUp() external {
        // Setup forked environment.
        checker = new MerkleTreeLeafChecker();
    }

    function testChecker() external {
        string memory signature = "supply(address,uint256,address,uint16)";
        address decoderAndSanitizer = 0xdaEfE2146908BAd73A1C45f75eB2B8E46935c781;
        address target = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
        bool canSendValue = false;
        address[] memory sensitiveArguments = new address[](2);
        sensitiveArguments[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        sensitiveArguments[1] = 0x917ceE801a67f933F2e6b33fC0cD1ED2d5909D88;

        bytes32 expectedHash = 0xb78a1e7f146baaf032e21da55bc9023d0a7539b11833ebee19e78515e4711b25;
        bytes32 calculatedHash =
            checker.checkLeaf(signature, decoderAndSanitizer, target, canSendValue, sensitiveArguments);

        assertTrue(calculatedHash == expectedHash, "Wrong hash");
    }
    // ========================================= HELPER FUNCTIONS =========================================

    function _startFork(string memory rpcKey, uint256 blockNumber) internal returns (uint256 forkId) {
        forkId = vm.createFork(vm.envString(rpcKey), blockNumber);
        vm.selectFork(forkId);
    }
}
