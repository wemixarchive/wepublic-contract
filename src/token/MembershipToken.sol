// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

import "./IMembershipToken.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Array } from "../lib/Array.sol";

/// @title MembershipToken
/// @author Mesher
/// @notice Grants the mebership of the DAO to the members by minting and buring membership tokens .
contract MembershipToken is
    IMembershipToken,
    ERC721EnumerableUpgradeable,
    ERC721VotesUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using Counters for Counters.Counter;

    using Array for bytes32[];

    address internal daoAddress;

    Counters.Counter internal tokenId;

    bytes32[] public roleNames;

    mapping(uint256 => bytes32) internal tokenIdToRole;

    mapping(uint256 => bool) internal _locked;

    mapping(address => uint256) internal _tokenIdsByOwner;

    address internal station;

    /// @notice A modifier to check if the caller is the station.
    modifier onlyStation() {
        require(msg.sender == station, "MembershipToken: caller is not the station");
        _;
    }

    /// @notice Disables the initializers on the implementation contract to prevent it from being left uninitialized.
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the Membership token by setting the name, symbol, roleNames and daoAddress.
    /// @param _name The name of the token.
    /// @param _symbol The symbol of the token.
    /// @param _roleNames The names of the roles to be used in the DAO.
    /// @param _daoAddress The Address of DAO to use the token.
    function initialize(
        string memory _name,
        string memory _symbol,
        bytes32[] memory _roleNames,
        address _daoAddress
    ) public virtual initializer {
        require(_roleNames.length > 0, "MembershipToken: roleNames is empty");

        __MembershipToken_init(_roleNames, _daoAddress);

        __ERC721_init(_name, _symbol);
        __ERC721Enumerable_init();
        __ERC721Votes_init();
        __Ownable_init();
    }

    /// @notice Sets the station that emits the membership tokens.
    /// @param _station The address of the DAO station.
    function setStation(address _station) external virtual onlyOwner {
        emit SetStation(daoAddress, station, _station);

        station = _station;
    }

    /// @notice Mints tokens to the valid memebers of the DAO.
    /// @param to The address of the member to mint the token to.
    /// @param role The role of the member to mint the token to.
    /// @return newTokenId The ID of the minted token.
    function mint(address to, bytes32 role) external virtual override onlyStation returns (uint256) {
        tokenId.increment();

        uint256 newTokenId = tokenId.current();

        _safeMint(to, newTokenId);

        _setRole(newTokenId, role);

        _tokenIdsByOwner[to] = newTokenId;

        _locked[newTokenId] = true;

        emit Locked(newTokenId);

        emit Mint(daoAddress, to, newTokenId, role);

        return newTokenId;
    }

    /// @notice Sets the role of the member.
    /// @param _tokenId The token ID of the member.
    /// @param _role The role of the member.
    function setRole(uint256 _tokenId, bytes32 _role) external virtual override onlyStation {
        _setRole(_tokenId, _role);
    }

    /// @notice Add a new role
    /// @param _role The role to be added.
    function addRole(bytes32 _role) external virtual override onlyStation {
        require(!roleNames.has(_role), "MembershipToken: role already exists");

        roleNames.push(_role);

        emit AddRole(daoAddress, _role);
    }

    /// @notice Remove a role
    /// @param _role The role to be removed.
    function removeRole(bytes32 _role) external virtual override onlyStation {
        require(roleNames.has(_role), "MembershipToken: role does not exist");

        roleNames.deleteByValue(_role);

        emit RemoveRole(daoAddress, _role);
    }

    /// @notice Burns tokens of the DAO members when they lose their membership.
    /// @param _tokenId The toekn ID of the member who will lose membership.
    function burn(uint256 _tokenId) public virtual onlyStation {
        require(_exists(_tokenId), "MembershipToken: token does not exist");

        address ownerOfToken = ownerOf(_tokenId);

        _burn(_tokenId);

        delete tokenIdToRole[_tokenId];

        delete _tokenIdsByOwner[ownerOfToken];

        delete _locked[_tokenId];

        emit Unlocked(_tokenId);

        emit Burn(daoAddress, _tokenId, ownerOfToken);
    }

    function getRoles() external view virtual override returns (bytes32[] memory) {
        return roleNames;
    }

    function getRole(uint256 _tokenId) external view virtual override returns (bytes32) {
        return tokenIdToRole[_tokenId];
    }

    /// @notice Finds token ID of the member.
    /// @param _owner The address of the member whose token ID is wanted to be found.
    /// @return The token ID of the member whose token ID is wanted to be found.
    function getMembershipId(address _owner) external view virtual override returns (uint256) {
        return _tokenIdsByOwner[_owner];
    }

    /// @notice Locks the tokenID so that is not transferable .
    /// @param _tokenId The toekn ID of the member.
    function locked(uint256 _tokenId) external view virtual override returns (bool) {
        return _locked[_tokenId];
    }

    /// @notice Calls the interfaces to use for memberhsip tokens.
    /// @param interfaceId Interface ID of the tokens will use.
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Upgradeable, ERC721EnumerableUpgradeable, IERC165Upgradeable) returns (bool) {
        return ERC721EnumerableUpgradeable.supportsInterface(interfaceId);
    }

    function _setRole(uint256 _tokenId, bytes32 _role) internal virtual {
        require(_exists(_tokenId), "MembershipToken: token does not exist");

        require(roleNames.has(_role), "MembershipToken: role does not exist");

        require(tokenIdToRole[_tokenId] != _role, "MembershipToken: given role is already set");

        emit SetRole(daoAddress, _tokenId, tokenIdToRole[_tokenId], _role);

        tokenIdToRole[_tokenId] = _role;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721Upgradeable, ERC721VotesUpgradeable) {
        ERC721VotesUpgradeable._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        ERC721EnumerableUpgradeable._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function __MembershipToken_init(
        bytes32[] memory _roleNames,
        address _daoAddress
    ) internal virtual onlyInitializing {
        for (uint256 i = 0; i < _roleNames.length; i++) {
            require(!roleNames.has(_roleNames[i]), "MembershipToken: role already exists");

            roleNames.push(_roleNames[i]);
        }

        daoAddress = _daoAddress;
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyStation {}
}
