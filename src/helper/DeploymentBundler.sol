// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Auth, Authority} from "@solmate/auth/Auth.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract DeploymentBundler is Auth {
    using Address for address;

    constructor(address _owner, Authority _auth) Auth(_owner, _auth) {}

    function submitBundle(address[] calldata targets, uint256[] calldata values, bytes[] calldata data)
        external
        requiresAuth
    {
        uint256 targetsLength = targets.length;
        if (targetsLength != values.length || targetsLength != data.length) {
            revert("DeploymentBundler: Invalid input");
        }

        for (uint256 i = 0; i < targetsLength; i++) {
            targets[i].functionCallWithValue(data[i], values[i]);
        }
    }
}
