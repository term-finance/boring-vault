// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {MainnetAddresses} from "test/resources/MainnetAddresses.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";
import {DeploymentBundler} from "src/helper/DeploymentBundler.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {Deployer} from "src/helper/Deployer.sol";

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

/**
 *  source .env && forge script script/DeployDeploymentBundler.s.sol:DeployDeploymentBundlerScript --evm-version london --broadcast --etherscan-api-key $MANTLESCAN_KEY --verify
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract DeployDeploymentBundlerScript is Script, ContractNames, MerkleTreeHelper {
    uint256 public privateKey;

    Deployer public deployer;
    RolesAuthority public rolesAuthority;
    address public owner;
    address public deploymentBundler;

    uint8 public constant DEPLOYER_ROLE = 1;

    function setUp() external {
        privateKey = vm.envUint("ETHERFI_LIQUID_DEPLOYER");
        vm.createSelectFork(mantle);
        setSourceChainName(mantle);
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        owner = getAddress(sourceChain, "dev0Address");
    }

    function run() external {
        bytes memory creationCode;
        bytes memory constructorArgs;
        vm.startBroadcast(privateKey);

        address deployedAddress = _getAddressIfDeployed(SevenSeasRolesAuthorityName);
        if (deployedAddress == address(0)) {
            creationCode = type(RolesAuthority).creationCode;
            constructorArgs = abi.encode(owner, Authority(address(0)));
            rolesAuthority =
                RolesAuthority(deployer.deployContract(SevenSeasRolesAuthorityName, creationCode, constructorArgs, 0));
        } else {
            rolesAuthority = RolesAuthority(deployedAddress);
        }

        creationCode = type(DeploymentBundler).creationCode;
        constructorArgs = abi.encode(owner, rolesAuthority);
        deploymentBundler = deployer.deployContract(DeploymentBundlerName, creationCode, constructorArgs, 0);

        deployer.setAuthority(rolesAuthority);

        rolesAuthority.setRoleCapability(DEPLOYER_ROLE, address(deployer), Deployer.deployContract.selector, true);
        rolesAuthority.setUserRole(deploymentBundler, DEPLOYER_ROLE, true);

        vm.stopBroadcast();
    }

    function _getAddressIfDeployed(string memory name) internal view returns (address) {
        address deployedAt = deployer.getAddress(name);
        uint256 size;
        assembly {
            size := extcodesize(deployedAt)
        }
        return size > 0 ? deployedAt : address(0);
    }
}
