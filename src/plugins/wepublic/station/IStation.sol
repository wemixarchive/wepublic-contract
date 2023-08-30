// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.11;

/// @title IStation
/// @author Mesher
/// @notice The interface for the Station plugin.

interface IStation {
    /// @notice Grants membership to a member of a DAO.
    /// @param owner The DAO contract.
    /// @param role The role to grant membership for.
    /// @dev The caller must have the `STATION_EXECUTOR_PERMISSION_ID` permission.
    function grantMembership(address owner, bytes32 role) external;

    /// @notice Sets a membership level.
    /// @param tokenId tokenId assgined for each DAO member .
    /// @param role The role to set membership for.
    function setMembershipRole(uint256 tokenId, bytes32 role) external;

    /// @notice Adds a membership role.
    /// @param role The role to add.
    function addMembershipRole(bytes32 role) external;

    /// @notice Removes a membership role.
    /// @param role The role to remove.
    function removeMembershipRole(bytes32 role) external;

    /// @notice Revokes membership of a member.
    /// @param tokenId tokenId assgined for each DAO member .
    /// @param to address of a DAO member whose membership is revoked .
    function revokeMembership(uint256 tokenId, address to) external;
}
