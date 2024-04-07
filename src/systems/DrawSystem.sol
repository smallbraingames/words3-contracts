// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

import { Letter } from "codegen/common.sol";
import { DrawLetterOdds } from "codegen/index.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { LibLetters } from "libraries/LibLetters.sol";
import { LibPrice } from "libraries/LibPrice.sol";

contract DrawSystem is System {
    error InvalidAddress();

    function draw(address player) public payable {
        if (player == address(0) || player == SINGLETON_ADDRESS) {
            revert InvalidAddress();
        }

        // Draw 8 letters for now, undecided on whether players can control
        Letter[] memory drawnLetters = LibLetters.getDraw({
            odds: DrawLetterOdds.get(),
            numLetters: 8,
            random: uint256(keccak256(abi.encodePacked(block.timestamp, _msgSender())))
        });

        for (uint256 i = 0; i < drawnLetters.length; i++) {
            LibLetters.addLetter({ player: player, letter: drawnLetters[i] });
        }
    }

    function getDrawPrice() public view returns (uint256) {
        return LibPrice.getDrawPrice();
    }
}
