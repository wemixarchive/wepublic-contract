// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.11;

import { PluginUUPSUpgradeable, IDAO } from "../../../core/plugin/PluginUUPSUpgradeable.sol";
import "./IStation.sol";
import "../../../token/IMembershipToken.sol";
import { IUUPS } from "../../../interface/IUUPS.sol";

/// @title StationBuild1
/// @author Mesehr
/// @notice This contract is deployed by the DAO and is used to grant, revoke and set membership roles for the DAO.
/// @dev This contract is upgradable.

contract StationBuild1 is IStation, PluginUUPSUpgradeable {
    IMembershipToken public membershipToken;

    /// @notice The ID of the permission required to call the `grantMembership`, `setMembershipRole`, `revokeMembership` function.
    bytes32 public constant STATION_EXECUTOR_PERMISSION_ID = keccak256("STATION_EXECUTOR_PERMISSION");

    /// @notice The ID of the permission required to call the `updateMembershipToken` function.
    bytes32 public constant STATION_UPDATOR_PERMISSION_ID = keccak256("STATION_UPDATOR_PERMISSION");

    /// @notice Initializes the station-plugin by storing a associated DAO and a related membership token.
    /// @param _dao The DAO contract.
    /// @param _membershipToken The Membership Token.
    function initializeBuild1(IDAO _dao, address _membershipToken) external initializer {
        __PluginUUPSUpgradeable_init(_dao);
        membershipToken = IMembershipToken(_membershipToken);
    }

    /// @notice A modifier to check if a memberhsip token is deployed.
    modifier tokenSet() {
        require(address(membershipToken) != address(0), "Station.tokenSet : Membership token is not set");
        _;
    }

    /// @notice Grants membership to a member of a DAO.
    /// @param owner The DAO contract.
    /// @param role The role to grant membership for.
    /// @dev The caller must have the `STATION_EXECUTOR_PERMISSION_ID` permission.
    function grantMembership(address owner, bytes32 role) external tokenSet auth(STATION_EXECUTOR_PERMISSION_ID) {
        require(membershipToken.getMembershipId(owner) == 0, "Station.grantMembership : SBT exist already"); // 토큰단에서 하기

        membershipToken.mint(owner, role);
    }

    /// @notice Sets a membership role.
    /// @param tokenId TokenId assgined for each DAO member .
    /// @param role The role to set membership for.
    /// @dev The caller must have the `STATION_EXECUTOR_PERMISSION_ID` permission.
    function setMembershipRole(uint256 tokenId, bytes32 role) external tokenSet auth(STATION_EXECUTOR_PERMISSION_ID) {
        membershipToken.setRole(tokenId, role);
    }

    /// @notice Adds a membership role.
    /// @param role The role to add.
    /// @dev The caller must have the `STATION_EXECUTOR_PERMISSION_ID` permission.
    function addMembershipRole(bytes32 role) external auth(STATION_EXECUTOR_PERMISSION_ID) {
        membershipToken.addRole(role);
    }

    /// @notice Removes a membership role.
    /// @param role The role to remove.
    /// @dev The caller must have the `STATION_EXECUTOR_PERMISSION_ID` permission.
    function removeMembershipRole(bytes32 role) external auth(STATION_EXECUTOR_PERMISSION_ID) {
        membershipToken.removeRole(role);
    }

    /// @notice Revokes membership of a member.
    /// @param tokenId TokenId assgined for each DAO member .
    /// @param to Address of a DAO member whose membership is revoked .
    /// @dev The caller must have the `STATION_EXECUTOR_PERMISSION_ID` permission.
    function revokeMembership(uint256 tokenId, address to) external tokenSet auth(STATION_EXECUTOR_PERMISSION_ID) {
        require(membershipToken.getMembershipId(to) == tokenId, "Station.revokeMembership : Token id mismatched");

        membershipToken.burn(tokenId);
    }

    /// @notice Upgrades a membership token.
    /// @param implementation Address of a new implementation contract.
    /// @dev The caller must have the `STATION_UPDATOR_PERMISSION_ID` permission.
    function upgradeMembershipToken(address implementation) external auth(STATION_UPDATOR_PERMISSION_ID) {
        IUUPS(address(membershipToken)).upgradeTo(implementation);
    }
}
