// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
