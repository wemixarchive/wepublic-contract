// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

import "./Strings.sol";

library Array {
    using Strings for string;

    function has(bytes32[] memory arr, bytes32 value) internal pure returns (bool) {
        uint256 len = arr.length;

        for (uint i = 0; i < len; i++) {
            if (value == arr[i]) {
                return true;
            }
        }

        return false;
    }

    function has(string[] memory arr, string memory value) internal pure returns (bool) {
        uint256 len = arr.length;

        for (uint i = 0; i < len; i++) {
            if (value.equal(arr[i])) {
                return true;
            }
        }

        return false;
    }

    function has(address[] memory arr, address value) internal pure returns (bool) {
        uint256 len = arr.length;

        for (uint i = 0; i < len; i++) {
            if (value == arr[i]) {
                return true;
            }
        }

        return false;
    }

    function has(uint256[] memory arr, uint256 value) internal pure returns (bool) {
        uint256 len = arr.length;

        for (uint i = 0; i < len; i++) {
            if (value == arr[i]) {
                return true;
            }
        }

        return false;
    }

    function get(bytes32[] memory arr) internal pure returns (bytes32[] memory) {
        uint len = arr.length;

        bytes32[] memory result = new bytes32[](len);

        for (uint i = 0; i < len; i++) {
            bytes32 str = arr[i];
            result[i] = str;
        }

        return result;
    }

    function get(string[] memory arr) internal pure returns (string[] memory) {
        uint len = arr.length;

        string[] memory result = new string[](len);

        for (uint i = 0; i < len; i++) {
            string memory str = arr[i];
            result[i] = str;
        }

        return result;
    }

    function get(address[] memory arr) internal pure returns (address[] memory) {
        uint len = arr.length;

        address[] memory result = new address[](len);

        for (uint i = 0; i < len; i++) {
            address addr = arr[i];
            result[i] = addr;
        }

        return result;
    }

    function get(uint256[] memory arr) internal pure returns (uint256[] memory) {
        uint len = arr.length;

        uint256[] memory result = new uint256[](len);

        for (uint i = 0; i < len; i++) {
            uint256 number = arr[i];
            result[i] = number;
        }

        return result;
    }

    function deleteByValue(bytes32[] storage arr, bytes32 value) internal {
        require(arr.length > 0, "Can't remove from empty array");

        uint256 len = arr.length;
        uint idx = len;

        for (uint i = 0; i < len; i++) {
            if (value == arr[i]) {
                idx = i;
                break;
            }
        }

        require(idx < len, "Value not found");

        arr[idx] = arr[len - 1];

        arr.pop();
    }

    function deleteByValue(string[] storage arr, string memory value) internal {
        require(arr.length > 0, "Can't remove from empty array");

        uint256 len = arr.length;
        uint idx = len;

        for (uint i = 0; i < len; i++) {
            if (value.equal(arr[i])) {
                idx = i;
                break;
            }
        }

        require(idx < len, "Value not found");

        arr[idx] = arr[len - 1];

        arr.pop();
    }

    function deleteByValue(address[] storage arr, address value) internal {
        require(arr.length > 0, "Can't remove from empty array");

        uint256 len = arr.length;
        uint idx = len;

        for (uint i = 0; i < len; i++) {
            if (value == arr[i]) {
                idx = i;
                break;
            }
        }

        require(idx < len, "Value not found");

        arr[idx] = arr[len - 1];

        arr.pop();
    }

    function deleteByValue(uint256[] storage arr, uint256 value) internal {
        require(arr.length > 0, "Can't remove from empty array");

        uint256 len = arr.length;
        uint idx = len;

        for (uint i = 0; i < len; i++) {
            if (value == arr[i]) {
                idx = i;
                break;
            }
        }

        require(idx < len, "Value not found");

        arr[idx] = arr[len - 1];

        arr.pop();
    }

    function deleteByIndex(bytes32[] storage arr, uint256 idx) internal {
        require(arr.length > 0, "Can't remove from empty array");
        require(idx < arr.length, "Index out of bounds");

        uint256 len = arr.length;

        arr[idx] = arr[len - 1];

        arr.pop();
    }

    function deleteByIndex(string[] storage arr, uint256 idx) internal {
        require(arr.length > 0, "Can't remove from empty array");
        require(idx < arr.length, "Index out of bounds");

        uint256 len = arr.length;

        arr[idx] = arr[len - 1];

        arr.pop();
    }

    function deleteByIndex(address[] storage arr, uint256 idx) internal {
        require(arr.length > 0, "Can't remove from empty array");
        require(idx < arr.length, "Index out of bounds");

        uint256 len = arr.length;

        arr[idx] = arr[len - 1];

        arr.pop();
    }

    function deleteByIndex(uint256[] storage arr, uint256 idx) internal {
        require(arr.length > 0, "Can't remove from empty array");
        require(idx < arr.length, "Index out of bounds");

        uint256 len = arr.length;

        arr[idx] = arr[len - 1];

        arr.pop();
    }
}
