// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Letter } from "codegen/common.sol";
import { DrawCount, DrawLetterOdds, LettersDrawn } from "codegen/index.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { LibLetters } from "libraries/LibLetters.sol";
import { LibPrice } from "libraries/LibPrice.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";

contract DrawSystem is System {
    error InvalidDrawAddress();
    error NotEnoughValue();

    function draw(address player) public payable {
        if (player == address(0) || player == SINGLETON_ADDRESS) {
            revert InvalidDrawAddress();
        }

        uint256 value = _msgValue();
        if (value < LibPrice.getDrawPrice()) {
            revert NotEnoughValue();
        }

        // Sender might be different than player, track the spend under sender
        LibTreasury.incrementTreasury(_msgSender(), value);

        // Draw 8 letters for now, undecided on whether players can control
        Letter[] memory drawnLetters = LibLetters.getDraw({
            odds: DrawLetterOdds.get(),
            numLetters: 8,
            random: uint256(keccak256(abi.encodePacked(block.timestamp, _msgSender())))
        });

        for (uint256 i = 0; i < drawnLetters.length; i++) {
            LibLetters.addLetter({ player: player, letter: drawnLetters[i] });
        }

        uint32 drawCount = DrawCount.get() + 1;
        DrawCount.set(drawCount);

        LettersDrawn.set({ id: drawCount, player: player, value: value, timestamp: block.timestamp });
    }

    function getDrawPrice() public view returns (uint256) {
        return LibPrice.getDrawPrice();
    }
}
