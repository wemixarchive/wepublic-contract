// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

import { PluginSetup, IPluginSetup } from "../../../framework/plugin/setup/PluginSetup.sol";
import { TreasuryBuild1 } from "./TreasuryBuild1.sol";
import { MirrorToken } from "../../../token/ERC20/MirrorToken.sol";
import { IMirrorToken } from "../../../token/ERC20/IMirrorToken.sol";
import { PermissionLib } from "../../../core/permission/PermissionLib.sol";
import { IOwnableUpgradeable } from "../../../interface/IOwnableUpgradeable.sol";

/// @title TreasuryBuild1Setup
/// @author Mesher
/// @notice The setup contract of the `TreasuryBuild1` plugin.
contract TreasuryBuild1Setup is PluginSetup {
    /// @notice The address of `TreasuryBuild1` plugin logic contract to be used in creating proxy contracts.
    TreasuryBuild1 private immutable treasuryImplementation;

    /// @notice The address of `Multisig` plugin logic contract to be used in creating proxy contracts.
    MirrorToken private immutable mirrorTokenImplementation;

    /// @notice The address of the treasury admin.
    address private treasuryAdmin;

    /// @notice The contract constructor, that deploys the `TreasuryBuild1` plugin logic contract.
    constructor() {
        treasuryImplementation = new TreasuryBuild1();
        mirrorTokenImplementation = new MirrorToken();
    }

    /// @notice Prepares the installation of a plugin.
    /// @param _dao The address of the installing DAO.
    /// @param _data The bytes-encoded data containing the input parameters for the installation as specified in the plugin's build metadata JSON file.
    /// @return plugin The address of the `Plugin` contract being prepared for installation.
    /// @return preparedSetupData The deployed plugin's relevant data which consists of helpers and permissions.
    function prepareInstallation(
        address _dao,
        bytes calldata _data
    ) external virtual override returns (address plugin, PreparedSetupData memory preparedSetupData) {
        (string memory _name, string memory _symbol, address _treasuryAdmin) = abi.decode(
            _data,
            (string, string, address)
        );

        treasuryAdmin = _treasuryAdmin;

        address mirrorToken;

        mirrorToken = createERC1967Proxy(
            address(mirrorTokenImplementation),
            abi.encodeWithSelector(MirrorToken.initialize.selector, _name, _symbol, _dao)
        );

        bytes memory initData = abi.encodeWithSelector(
            bytes4(keccak256("initializeBuild1(address,address)")),
            _dao,
            mirrorToken
        );

        plugin = createERC1967Proxy(address(treasuryImplementation), initData);

        IMirrorToken(mirrorToken).setTreasury(plugin);

        IOwnableUpgradeable(mirrorToken).transferOwnership(plugin);

        PermissionLib.MultiTargetPermission[] memory permissions = new PermissionLib.MultiTargetPermission[](2);

        address[] memory helpers = new address[](1);

        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            treasuryAdmin,
            PermissionLib.NO_CONDITION,
            treasuryImplementation.TREASURY_EXECUTOR_PERMISSION_ID()
        );

        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            _dao,
            PermissionLib.NO_CONDITION,
            treasuryImplementation.TREASURY_UPDATOR_PERMISSION_ID()
        );

        helpers[0] = mirrorToken;

        preparedSetupData.helpers = helpers;
        preparedSetupData.permissions = permissions;

        return (plugin, preparedSetupData);
    }

    /// @notice Prepares the uninstallation of a plugin.
    /// @param _dao The address of the uninstalling DAO.
    /// @param _payload The relevant data necessary for the `prepareUninstallation`. See above.
    /// @return permissions The array of multi-targeted permission operations to be applied by the `PluginSetupProcessor` to the uninstalling DAO.
    function prepareUninstallation(
        address _dao,
        SetupPayload calldata _payload
    ) external virtual override returns (PermissionLib.MultiTargetPermission[] memory permissions) {
        permissions = new PermissionLib.MultiTargetPermission[](2);

        permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _payload.plugin,
            treasuryAdmin,
            PermissionLib.NO_CONDITION,
            treasuryImplementation.TREASURY_EXECUTOR_PERMISSION_ID()
        );

        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _payload.plugin,
            _dao,
            PermissionLib.NO_CONDITION,
            treasuryImplementation.TREASURY_UPDATOR_PERMISSION_ID()
        );
    }

    /// @notice Returns the plugin implementation address.
    /// @return The address of the plugin implementation contract.
    function implementation() external view virtual override returns (address) {
        return address(treasuryImplementation);
    }
}
