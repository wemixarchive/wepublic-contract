// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

/// @title ITreasury
/// @author Mesher
/// @notice The interface for the Treasury plugin.
interface ITreasury {
    /// @notice Mint mirror token.
    /// @param amount amount of mirror token to be minted.
    function mintMirrorToken(uint256 amount) external;

    /// @notice Burn mirror token.
    /// @param amount amount of mirror token to be burned.
    function burnMirrorToken(uint256 amount) external;
}
