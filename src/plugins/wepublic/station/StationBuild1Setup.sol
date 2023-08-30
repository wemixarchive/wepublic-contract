// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

import { PluginSetup, IPluginSetup } from "../../../framework/plugin/setup/PluginSetup.sol";
import { StationBuild1 } from "./StationBuild1.sol";
import { MembershipToken } from "../../../token/MembershipToken.sol";
import { IMembershipToken } from "../../../token/IMembershipToken.sol";
import { PermissionLib } from "../../../core/permission/PermissionLib.sol";
import { IOwnableUpgradeable } from "../../../interface/IOwnableUpgradeable.sol";

/// @title StationBuild1Setup
/// @author Mesher
/// @notice The setup contract of the `StationBuild1` plugin.
contract StationBuild1Setup is PluginSetup {
    /// @notice The address of `StationBuild1` plugin logic contract to be used in creating proxy contracts.
    StationBuild1 private immutable stationImplementation;

    /// @notice The address of `MembershipToken` plugin logic contract to be used in creating proxy contracts.
    MembershipToken private immutable membershipTokenImplementation;

    /// @notice The address of the station admin.
    address private stationAdmin;

    /// @notice The contract constructor, that deploys the `StationBuild` plugin logic contract.
    constructor() {
        stationImplementation = new StationBuild1();
        membershipTokenImplementation = new MembershipToken();
    }

    /// @notice The local variables associated with a prepared setup.
    /// @param initData Initialization data for a DAO.
    /// @param permissions The array of multi-targeted permission operations to be applied by the `PluginSetupProcessor` to the installing or updating DAO.
    /// @param helpers The address array of helpers (contracts or EOAs) associated with this plugin version after the installation or update.
    struct PrepareInstallationLocalVars {
        address membershipToken;
        string name;
        string symbol;
        bytes32[] roleNames;
        address stationAdmin;
        address dao;
        bytes initData;
        PermissionLib.MultiTargetPermission[] permissions;
        address[] helpers;
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
        (string memory _name, string memory _symbol, bytes32[] memory _roleNames, address _stationAdmin) = abi.decode(
            _data,
            (string, string, bytes32[], address)
        );

        for (uint i = 0; i < _roleNames.length; i++) {}

        PrepareInstallationLocalVars memory vars;

        vars.name = _name;
        vars.symbol = _symbol;
        vars.roleNames = _roleNames;
        vars.stationAdmin = _stationAdmin;
        vars.dao = _dao;

        stationAdmin = vars.stationAdmin;

        vars.membershipToken = createERC1967Proxy(
            address(membershipTokenImplementation),
            abi.encodeWithSelector(
                MembershipToken.initialize.selector,
                vars.name,
                vars.symbol,
                vars.roleNames,
                vars.dao
            )
        );

        vars.initData = abi.encodeWithSelector(
            bytes4(keccak256("initializeBuild1(address,address)")),
            vars.dao,
            vars.membershipToken
        );

        plugin = createERC1967Proxy(address(stationImplementation), vars.initData);

        IMembershipToken(vars.membershipToken).setStation(plugin);

        IOwnableUpgradeable(vars.membershipToken).transferOwnership(plugin);

        vars.permissions = new PermissionLib.MultiTargetPermission[](2);

        vars.helpers = new address[](1);

        vars.permissions[0] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            stationAdmin,
            PermissionLib.NO_CONDITION,
            stationImplementation.STATION_EXECUTOR_PERMISSION_ID()
        );

        vars.permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Grant,
            plugin,
            vars.dao,
            PermissionLib.NO_CONDITION,
            stationImplementation.STATION_UPDATOR_PERMISSION_ID()
        );

        vars.helpers[0] = vars.membershipToken;

        preparedSetupData.helpers = vars.helpers;
        preparedSetupData.permissions = vars.permissions;

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
            stationAdmin,
            PermissionLib.NO_CONDITION,
            stationImplementation.STATION_EXECUTOR_PERMISSION_ID()
        );

        permissions[1] = PermissionLib.MultiTargetPermission(
            PermissionLib.Operation.Revoke,
            _payload.plugin,
            _dao,
            PermissionLib.NO_CONDITION,
            stationImplementation.STATION_UPDATOR_PERMISSION_ID()
        );
    }

    /// @notice Returns the plugin implementation address.
    /// @return The address of the plugin implementation contract.
    function implementation() external view virtual override returns (address) {
        return address(stationImplementation);
    }
}
