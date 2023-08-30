// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

import "./ERC5192/IERC5192.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

/// @title IMembershipToken
/// @notice Interface of Membership tokens.
interface IMembershipToken is IERC5192, IERC721Upgradeable {
    event SetStation(address daoAddress, address indexed previousStation, address indexed newStation);

    event SetBaseURI(address daoAddress, string previousBaseURI, string newBaseURI);

    event Mint(address daoAddress, address indexed to, uint256 indexed tokenId, bytes32 role);

    event SetRole(address daoAddress, uint256 indexed tokenId, bytes32 oldRole, bytes32 newRole);

    event AddRole(address daoAddress, bytes32 indexed role);

    event RemoveRole(address daoAddress, bytes32 indexed role);

    event Burn(address daoAddress, uint256 indexed tokenId, address from);

    function getMembershipId(address owner) external view returns (uint256);

    function getRoles() external view returns (bytes32[] memory);

    function getRole(uint256 tokenId) external view returns (bytes32);

    function setStation(address _station) external;

    function mint(address to, bytes32 role) external returns (uint256);

    function setRole(uint256 tokenId, bytes32 role) external;

    function addRole(bytes32 role) external;

    function removeRole(bytes32 role) external;

    function burn(uint256 tokenId) external;
}
