// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.11;

import { PluginUUPSUpgradeable, IDAO } from "../../../core/plugin/PluginUUPSUpgradeable.sol";
import "./ITreasury.sol";
import "../../../token/ERC20/IMirrorToken.sol";
import { IUUPS } from "../../../interface/IUUPS.sol";

/// @title TreasuryBuild1
/// @author Mesher
/// @notice This contract is deployed by the DAO and is used to mint, burn and update mirror token for the DAO.
/// @dev This contract is upgradable.
contract TreasuryBuild1 is ITreasury, PluginUUPSUpgradeable {
    IMirrorToken public mirrorToken;

    /// @notice The ID of the permission required to call the `mintMirrorToken`, `burnMirrorToken` function.
    bytes32 public constant TREASURY_EXECUTOR_PERMISSION_ID = keccak256("TREASURY_EXECUTOR_PERMISSION");

    /// @notice The ID of the permission required to call the `updateMirrorToken` function.
    bytes32 public constant TREASURY_UPDATOR_PERMISSION_ID = keccak256("TREASURY_UPDATOR_PERMISSION");

    /// @notice Initializes the treasury-plugin by storing a associated DAO and a related membership token.
    /// @param _dao The DAO contract.
    /// @param _mirrorToken The mirror Token.
    function initializeBuild1(IDAO _dao, address _mirrorToken) external initializer {
        __PluginUUPSUpgradeable_init(_dao);
        mirrorToken = IMirrorToken(_mirrorToken);
    }

    /// @notice A modifier to check if a mirror token is deployed.
    modifier tokenSet() {
        require(address(mirrorToken) != address(0), "Treasury.tokenSet : Mirror token is not set");
        _;
    }

    /// @notice Mint mirror token.
    /// @param amount amount of mirror token to be minted.
    function mintMirrorToken(uint256 amount) external tokenSet auth(TREASURY_EXECUTOR_PERMISSION_ID) {
        mirrorToken.mint(amount);
    }

    /// @notice Burn mirror token.
    /// @param amount amount of mirror token to be burned.
    function burnMirrorToken(uint256 amount) external tokenSet auth(TREASURY_EXECUTOR_PERMISSION_ID) {
        mirrorToken.burn(amount);
    }

    /// @notice Upgrades a mirror token.
    /// @param implementation The address of a new implementation.
    /// @dev The caller must have the `TREASURY_UPDATOR_PERMISSION_ID` permission.
    function upgradeMirrorToken(address implementation) external auth(TREASURY_UPDATOR_PERMISSION_ID) {
        IUUPS(address(mirrorToken)).upgradeTo(implementation);
    }
}
