// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

import "./IMirrorToken.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Mirrortoken
/// @author Mesher
/// @notice Mint and burn mirror totkens so that the token can keep track of deposited money in DAO.
contract MirrorToken is IMirrorToken, ERC20PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    address internal treasury;

    address internal daoAddress;

    modifier onlyTreasury() {
        require(msg.sender == treasury, "MirrorToken: caller is not the treasury");
        _;
    }

    /// @notice Disables the initializers on the implementation contract to prevent it from being left uninitialized.
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the contract.
    /// @param _name The name of the token.
    /// @param _symbol The symbol of the token.
    /// @param _daoAddress The Address of dao owning the mirror tokens.
    function initialize(string memory _name, string memory _symbol, address _daoAddress) public virtual initializer {
        __MirrorToken_init(_daoAddress);

        __ERC20_init(_name, _symbol);
        __ERC20Pausable_init();
        __Ownable_init();
        _pause();
    }

    /// @notice Sets the treasury of the DAO which owns mirror tokens .
    /// @param _treasury The address of the DAO treasury .
    function setTreasury(address _treasury) external virtual onlyOwner {
        emit SetTreasury(daoAddress, treasury, _treasury);

        treasury = _treasury;
    }

    /// @notice Mints tokens to the treasury.
    /// @param amount The amount of tokens to be minted.
    function mint(uint256 amount) external virtual override onlyTreasury whenPaused {
        _unpause();

        _mint(treasury, amount);

        emit Mint(daoAddress, treasury, amount);

        _pause();
    }

    /// @notice Burns tokens in the treasury.
    /// @param amount The amount of tokens to be bruned.
    function burn(uint256 amount) external virtual override onlyTreasury whenPaused {
        _unpause();

        _burn(treasury, amount);

        emit Burn(daoAddress, treasury, amount);

        _pause();
    }

    function __MirrorToken_init(address _daoAddress) internal virtual onlyInitializing {
        daoAddress = _daoAddress;
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyTreasury {}
}
