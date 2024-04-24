// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { DrawLetterOdds } from "codegen/index.sol";

contract SetDrawLetterOddsSystem is System {
    error AlreadySetOdds();
    error InvalidOddsLength();
    error NonzeroFirstValue();

    function setDrawLetterOdds(uint8[] memory odds) public {
        if (DrawLetterOdds.get().length != 0) {
            revert AlreadySetOdds();
        }
        if (odds.length != 27) {
            revert InvalidOddsLength();
        }
        if (odds[0] != 0) {
            revert NonzeroFirstValue();
        }
        DrawLetterOdds.set(odds);
    }
}
