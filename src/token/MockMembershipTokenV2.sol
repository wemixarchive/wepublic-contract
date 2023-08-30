// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

import "./MembershipToken.sol";

/// @title MembershipToken
/// @author Mesher
/// @notice Grants the mebership of the DAO to the members by minting and buring membership tokens .
contract MockMembershipTokenV2 is MembershipToken {
    function mint(address to, bytes32 role) external override onlyStation returns (uint256) {
        emit Mint(daoAddress, to, type(uint256).max, "MEMBER");
    }
}
