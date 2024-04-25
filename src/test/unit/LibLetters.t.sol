// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Letter } from "codegen/common.sol";
import "forge-std/Test.sol";
import { LibLetters } from "libraries/LibLetters.sol";

contract LibLettersTest is Words3Test {
    function test_GetDraw() public {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp)));

        uint8[] memory odds = new uint8[](27);
        odds[0] = 0;
        odds[uint8(Letter.A)] = 1;
        odds[uint8(Letter.B)] = 0;
        odds[uint8(Letter.C)] = 0;
        odds[uint8(Letter.D)] = 0;
        odds[uint8(Letter.E)] = 1;
        odds[uint8(Letter.F)] = 0;
        odds[uint8(Letter.G)] = 0;

        Letter[] memory letters = LibLetters.getDraw(odds, 8, random);

        assertEq(letters.length, 8);
        for (uint256 i = 0; i < letters.length; i++) {
            assertTrue(letters[i] == Letter.A || letters[i] == Letter.E);
        }
    }

    function testFuzz_GetDraw(uint256 random) public {
        uint8[] memory odds = new uint8[](27);
        odds[0] = 0;
        odds[uint8(Letter.A)] = 0;
        odds[uint8(Letter.B)] = 1;
        odds[uint8(Letter.C)] = 0;
        odds[uint8(Letter.D)] = 1;
        odds[uint8(Letter.E)] = 1;
        odds[uint8(Letter.F)] = 0;
        odds[uint8(Letter.G)] = 0;

        Letter[] memory letters = LibLetters.getDraw(odds, 8, random);

        assertEq(letters.length, 8);
        for (uint256 i = 0; i < letters.length; i++) {
            assertTrue(letters[i] == Letter.B || letters[i] == Letter.D || letters[i] == Letter.E);
        }
    }
}
