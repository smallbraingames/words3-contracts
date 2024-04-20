// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Letter } from "codegen/common.sol";
import { LibLetters } from "libraries/LibLetters.sol";

contract TransferLettersSystem is System {
    error TransferMissingLetters();

    function transfer(Letter[] memory letters, address to) public {
        address from = _msgSender();

        if (!LibLetters.hasLetters({ player: from, letters: letters })) {
            revert TransferMissingLetters();
        }

        for (uint256 i = 0; i < letters.length; i++) {
            LibLetters.removeLetter({ player: from, letter: letters[i] });
            LibLetters.addLetter({ player: to, letter: letters[i] });
        }
    }
}
