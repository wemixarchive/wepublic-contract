// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

import { IDAO } from "../../../core/dao/IDAO.sol";
import { InterfaceBasedRegistry } from "../../utils/InterfaceBasedRegistry.sol";
import { IPluginRepo } from "./IPluginRepo.sol";

/// @title PluginRepoRegistry
/// @author Aragon Association - 2022-2023
/// @notice This contract maintains an address-based registry of plugin repositories in the Aragon App DAO framework.
contract PluginRepoRegistry is InterfaceBasedRegistry {
    /// @notice The ID of the permission required to call the `register` function.
    bytes32 public constant REGISTER_PLUGIN_REPO_PERMISSION_ID = keccak256("REGISTER_PLUGIN_REPO_PERMISSION");

    /// @notice Emitted if a new plugin repository is registered.
    /// @param pluginRepo The address of the plugin repository.
    event PluginRepoRegistered(address pluginRepo);

    /// @dev Used to disallow initializing the implementation contract by an attacker for extra safety.
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the contract by setting calling the `InterfaceBasedRegistry` base class initialize method.
    /// @param _dao The address of the managing DAO.
    function initialize(IDAO _dao) external initializer {
        bytes4 pluginRepoInterfaceId = type(IPluginRepo).interfaceId;
        __InterfaceBasedRegistry_init(_dao, pluginRepoInterfaceId);
    }

    /// @notice Registers a plugin repository.
    /// @param pluginRepo The address of the PluginRepo contract.
    function registerPluginRepo(address pluginRepo) external auth(REGISTER_PLUGIN_REPO_PERMISSION_ID) {
        _register(pluginRepo);

        emit PluginRepoRegistered(pluginRepo);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add new variables without shifting down storage in the inheritance chain (see [OpenZeppelin's guide about storage gaps](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[49] private __gap;
}
