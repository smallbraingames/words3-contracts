// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

import { Letter } from "codegen/common.sol";
import { DrawCount, DrawLetterOdds, DrawUpdate, GameConfig } from "codegen/index.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { LibLetters } from "libraries/LibLetters.sol";
import { LibPrice } from "libraries/LibPrice.sol";

import { LibTreasury } from "libraries/LibTreasury.sol";
import { LibUpdateId } from "libraries/LibUpdateId.sol";

contract DrawSystem is System {
    error InvalidDrawAddress();
    error NotEnoughValue();

    function draw(address player) public payable {
        if (player == SINGLETON_ADDRESS) {
            revert InvalidDrawAddress();
        }

        uint256 value = _msgValue();
        if (value < LibPrice.getDrawPrice()) {
            revert NotEnoughValue();
        }

        // Sender might be different than player, track the spend under sender
        LibTreasury.incrementTreasury({ msgSender: _msgSender(), msgValue: value });

        uint32 drawCount = DrawCount.get() + 1;
        uint256 random = uint256(keccak256(abi.encodePacked(block.prevrandao, drawCount)));
        Letter[] memory drawnLetters = LibLetters.getDraw({
            odds: DrawLetterOdds.get(),
            numLetters: GameConfig.getNumDrawLetters(),
            random: random
        });

        for (uint256 i = 0; i < drawnLetters.length; i++) {
            LibLetters.addLetter({ player: player, letter: drawnLetters[i] });
        }

        DrawCount.set({ value: drawCount });

        DrawUpdate.set({ id: LibUpdateId.getUpdateId(), player: player, value: value, timestamp: block.timestamp });
    }

    function getDrawPrice() public view returns (uint256) {
        return LibPrice.getDrawPrice();
    }
}
