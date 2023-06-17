// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Letter, Status} from "codegen/Types.sol";

import {Coord} from "common/Coord.sol";
import {GameStartedOrOver} from "common/Errors.sol";
import {LibTile} from "libraries/LibTile.sol";
import {LibGame} from "libraries/LibGame.sol";

import {System} from "@latticexyz/world/src/System.sol";

contract StartSystem is System {
    function start(
        Letter[] memory initialWord,
        uint16 maxWords,
        bytes32 merkleRoot,
        int256 vrgdaTargetPrice,
        int256 vrgdaPriceDecay,
        int256 vrgdaPerDay
    ) public {
        if (LibGame.getGameStatus() != Status.NOT_STARTED) {
            revert GameStartedOrOver();
        }
        for (uint256 i = 0; i < initialWord.length; i++) {
            Coord memory coord = Coord({x: int32(uint32(i)), y: 0});
            LibTile.setTile(coord, initialWord[i], address(0));
        }
        LibGame.startGame(maxWords, merkleRoot, vrgdaTargetPrice, vrgdaPriceDecay, vrgdaPerDay);
    }
}
