// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/// @title IMirrorToken
/// @notice Interface of Mirror tokens.
interface IMirrorToken is IERC20Upgradeable {
    event SetTreasury(address daoAddress, address indexed previousTreasury, address indexed newTreasury);

    event Mint(address daoAddress, address indexed to, uint256 amount);

    event Burn(address daoAddress, address indexed to, uint256 amount);

    /// @notice Mints tokens to the treasury.
    /// @param amount The amount of tokens to be minted.
    function mint(uint256 amount) external;

    /// @notice Burns tokens in the treasury.
    /// @param amount The amount of tokens to be bruned.
    function burn(uint256 amount) external;

    /// @notice Sets the treasury of the DAO which owns mirror tokens .
    /// @param _treasury The address of the DAO treasury .
    function setTreasury(address _treasury) external;
}
