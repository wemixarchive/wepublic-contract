// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.11;

import "./MirrorToken.sol";

contract MockMirrorTokenV2 is MirrorToken {
    uint256 internal _nonce;

    function getNonce() external view returns (uint256) {
        return _nonce;
    }

    function mintV2(uint256 amount, uint256 nonce) external whenPaused {
        require(_nonce + 1 == nonce, "MirrorToken.mint : nonce isnt valid");

        _unpause();

        _mint(treasury, amount);

        unchecked {
            _nonce++;
        }

        emit Mint(daoAddress, treasury, amount);

        _pause();
    }

    // @TODO
    // error Deprecated ();

    // function mint(uint256 amount) external onlyTreasury whenPaused override(MirrorToken) {
    //     revert Deprecated();
    // }
}
