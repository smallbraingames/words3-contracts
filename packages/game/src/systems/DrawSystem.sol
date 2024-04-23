// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Letter } from "codegen/common.sol";
import { DrawCount, DrawLetterOdds, DrawRequest, DrawRequestData, LettersDrawn } from "codegen/index.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { LibLetters } from "libraries/LibLetters.sol";
import { LibPrice } from "libraries/LibPrice.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";
import { Response } from "rng/src/codegen/index.sol";
import { IWorld } from "rng/src/codegen/world/IWorld.sol";

contract DrawSystem is System {
    error InvalidDrawAddress();
    error NotEnoughValue();
    error AlreadyFulfilled();

    function requestDraw(address player) public payable returns (uint256) {
        if (player == address(0) || player == SINGLETON_ADDRESS) {
            revert InvalidDrawAddress();
        }

        uint256 value = _msgValue();
        if (value < LibPrice.getDrawPrice()) {
            revert NotEnoughValue();
        }

        // Sender might be different than player, track the spend under sender
        LibTreasury.incrementTreasury(_msgSender(), value);

        IWorld world = IWorld(_world());
        uint256 id = world.rng__request({ period: 1 });

        DrawRequest.set({ id: id, player: player, fulfilled: false });

        LettersDrawn.set({ id: id, player: player, value: value, timestamp: block.timestamp });

        return id;
    }

    function fulfillDraw(uint256 id) public {
        DrawRequestData memory request = DrawRequest.get({ id: id });
        if (request.fulfilled) {
            revert AlreadyFulfilled();
        }
        address player = request.player;

        uint256 random = Response.getValue({ id: id });
        if (random == 0) {
            IWorld world = IWorld(_world());
            world.rng__setRandao({ id: id });
        }
        random = Response.getValue({ id: id });

        // Draw 8 letters for now, undecided on whether players can control
        Letter[] memory drawnLetters = LibLetters.getDraw({
            odds: DrawLetterOdds.get(),
            numLetters: 8,
            random: uint256(keccak256(abi.encodePacked(random, _msgSender(), id)))
        });

        for (uint256 i = 0; i < drawnLetters.length; i++) {
            LibLetters.addLetter({ player: player, letter: drawnLetters[i] });
        }

        uint32 drawCount = DrawCount.get() + 1;
        DrawCount.set(drawCount);
        DrawRequest.setFulfilled({ id: id, fulfilled: true });
    }

    function getDrawPrice() public view returns (uint256) {
        return LibPrice.getDrawPrice();
    }
}
