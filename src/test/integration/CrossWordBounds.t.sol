// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import { Direction, Letter } from "codegen/common.sol";
import { FeeConfigData, PriceConfigData, TileLetter } from "codegen/index.sol";
import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";
import "forge-std/Test.sol";

contract CrossWord is Words3Test {
    bytes32[] public words;
    Merkle private m;

    function setUp() public override {
        super.setUp();

        m = new Merkle();
        Letter[] memory bed = new Letter[](3);
        bed[0] = Letter.B;
        bed[1] = Letter.E;
        bed[2] = Letter.D;

        Letter[] memory does = new Letter[](4);
        does[0] = Letter.D;
        does[1] = Letter.O;
        does[2] = Letter.E;
        does[3] = Letter.S;

        Letter[] memory be = new Letter[](2);
        be[0] = Letter.B;
        be[1] = Letter.E;

        Letter[] memory bee = new Letter[](3);
        bee[0] = Letter.B;
        bee[1] = Letter.E;
        bee[2] = Letter.E;

        Letter[] memory dose = new Letter[](4);
        dose[0] = Letter.D;
        dose[1] = Letter.O;
        dose[2] = Letter.S;
        dose[3] = Letter.E;

        Letter[] memory oblong = new Letter[](6);
        oblong[0] = Letter.O;
        oblong[1] = Letter.B;
        oblong[2] = Letter.L;
        oblong[3] = Letter.O;
        oblong[4] = Letter.N;
        oblong[5] = Letter.G;

        Letter[] memory eb = new Letter[](2);
        eb[0] = Letter.E;
        eb[1] = Letter.B;

        Letter[] memory bo = new Letter[](2);
        bo[0] = Letter.B;
        bo[1] = Letter.O;

        Letter[] memory testInvalidEmptyBed = new Letter[](4);
        testInvalidEmptyBed[0] = Letter.B;
        testInvalidEmptyBed[1] = Letter.E;
        testInvalidEmptyBed[2] = Letter.EMPTY;
        testInvalidEmptyBed[3] = Letter.D;

        Letter[] memory testInvalidEmptyDb = new Letter[](3);
        testInvalidEmptyDb[0] = Letter.D;
        testInvalidEmptyDb[1] = Letter.EMPTY;
        testInvalidEmptyDb[2] = Letter.B;

        words.push(keccak256(bytes.concat(keccak256(abi.encode(bed))))); // bed 0
        words.push(keccak256(bytes.concat(keccak256(abi.encode(does))))); // does 1
        words.push(keccak256(bytes.concat(keccak256(abi.encode(be))))); // be 2
        words.push(keccak256(bytes.concat(keccak256(abi.encode(bee))))); // bee 3
        words.push(keccak256(bytes.concat(keccak256(abi.encode(dose))))); // dose 4
        words.push(keccak256(bytes.concat(keccak256(abi.encode(oblong))))); // oblong 5
        words.push(keccak256(bytes.concat(keccak256(abi.encode(eb))))); // eb 6
        words.push(keccak256(bytes.concat(keccak256(abi.encode(bo))))); // bo 7
        words.push(keccak256(bytes.concat(keccak256(abi.encode(testInvalidEmptyBed))))); // testInvalidEmptyBed 8
        words.push(keccak256(bytes.concat(keccak256(abi.encode(testInvalidEmptyDb))))); // testInvalidEmptyDb 9

        setDefaultLetterOdds();

        address player = address(0xface);
        uint32[26] memory initialLetterAllocation;
        initialLetterAllocation[uint8(Letter.B) - 1] = 100;
        initialLetterAllocation[uint8(Letter.E) - 1] = 100;
        initialLetterAllocation[uint8(Letter.D) - 1] = 100;
        initialLetterAllocation[uint8(Letter.O) - 1] = 100;
        initialLetterAllocation[uint8(Letter.S) - 1] = 100;
        initialLetterAllocation[uint8(Letter.L) - 1] = 100;
        initialLetterAllocation[uint8(Letter.N) - 1] = 100;
        initialLetterAllocation[uint8(Letter.G) - 1] = 100;
        Letter[] memory initialWord = new Letter[](8); // infinite
        initialWord[0] = Letter.I;
        initialWord[1] = Letter.N;
        initialWord[2] = Letter.F;
        initialWord[3] = Letter.I;
        initialWord[4] = Letter.N;
        initialWord[5] = Letter.I;
        initialWord[6] = Letter.T;
        initialWord[7] = Letter.E;

        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: player,
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.9e18,
                wadScale: 9.96e36
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 10,
            numDrawLetters: 7
        });

        vm.startPrank(player);
        Bound[] memory bedBounds = new Bound[](3);
        Letter[] memory playBed = new Letter[](3);
        playBed[0] = Letter.B;
        playBed[1] = Letter.EMPTY;
        playBed[2] = Letter.D;
        world.play({
            word: playBed,
            proof: m.getProof(words, 0),
            coord: Coord({ x: 3, y: -1 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: bedBounds
        });

        Bound[] memory doesBound = new Bound[](4);
        Letter[] memory playDoes = new Letter[](4);
        playDoes[0] = Letter.EMPTY;
        playDoes[1] = Letter.O;
        playDoes[2] = Letter.E;
        playDoes[3] = Letter.S;
        world.play({
            word: playDoes,
            proof: m.getProof(words, 1),
            coord: Coord({ x: 3, y: 1 }),
            direction: Direction.LEFT_TO_RIGHT,
            bounds: doesBound
        });

        // Some checks for fun
        assertEq(uint8(TileLetter.get({ x: 3, y: -1 })), uint8(Letter.B));
        assertEq(uint8(TileLetter.get({ x: 3, y: 0 })), uint8(Letter.E));
        assertEq(uint8(TileLetter.get({ x: 3, y: 1 })), uint8(Letter.D));
        assertEq(uint8(TileLetter.get({ x: 4, y: 1 })), uint8(Letter.O));
        assertEq(uint8(TileLetter.get({ x: 5, y: 1 })), uint8(Letter.E));
        assertEq(uint8(TileLetter.get({ x: 6, y: 1 })), uint8(Letter.S));

        // Play oblong
        Bound[] memory oblongBounds = new Bound[](6);
        Letter[] memory playOblong = new Letter[](6);
        playOblong[0] = Letter.EMPTY;
        playOblong[1] = Letter.B;
        playOblong[2] = Letter.L;
        playOblong[3] = Letter.O;
        playOblong[4] = Letter.N;
        playOblong[5] = Letter.G;
        world.play({
            word: playOblong,
            proof: m.getProof(words, 5),
            coord: Coord({ x: 4, y: 1 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: oblongBounds
        });

        // Play bee
        Bound[] memory beeBounds = new Bound[](3);
        beeBounds[2] = Bound({ positive: 0, negative: 1, proof: m.getProof(words, 2) });
        Letter[] memory playBee = new Letter[](3);
        playBee[0] = Letter.B;
        playBee[1] = Letter.EMPTY;
        playBee[2] = Letter.E;
        world.play({
            word: playBee,
            proof: m.getProof(words, 3),
            coord: Coord({ x: 5, y: 0 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: beeBounds
        });

        Letter[] memory playBe1 = new Letter[](2);
        playBe1[0] = Letter.EMPTY;
        playBe1[1] = Letter.E;

        Letter[] memory playBe2 = new Letter[](2);
        playBe2[0] = Letter.B;
        playBe2[1] = Letter.EMPTY;
        // Play be
        Bound[] memory beBounds = new Bound[](2);
        world.play({
            word: playBe1,
            proof: m.getProof(words, 2),
            coord: Coord({ x: 3, y: -1 }),
            direction: Direction.LEFT_TO_RIGHT,
            bounds: beBounds
        });

        world.play({
            word: playBe2,
            proof: m.getProof(words, 2),
            coord: Coord({ x: 4, y: -2 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: beBounds
        });

        world.play({
            word: playBe1,
            proof: m.getProof(words, 2),
            coord: Coord({ x: 4, y: -2 }),
            direction: Direction.LEFT_TO_RIGHT,
            bounds: beBounds
        });

        world.play({
            word: playBe2,
            proof: m.getProof(words, 2),
            coord: Coord({ x: 5, y: -3 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: beBounds
        });

        Bound[] memory bee2Bounds = new Bound[](3);
        Letter[] memory playBee2 = new Letter[](3);
        playBee2[0] = Letter.EMPTY;
        playBee2[1] = Letter.E;
        playBee2[2] = Letter.E;
        world.play({
            word: playBee2,
            proof: m.getProof(words, 3),
            coord: Coord({ x: 5, y: -3 }),
            direction: Direction.LEFT_TO_RIGHT,
            bounds: bee2Bounds
        });

        // play eb
        Bound[] memory ebBounds = new Bound[](2);
        Letter[] memory playEb = new Letter[](2);
        playEb[0] = Letter.EMPTY;
        playEb[1] = Letter.B;
        world.play({
            word: playEb,
            proof: m.getProof(words, 6),
            coord: Coord({ x: 7, y: -3 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: ebBounds
        });

        world.play({
            word: playBe1,
            proof: m.getProof(words, 2),
            coord: Coord({ x: 7, y: -2 }),
            direction: Direction.LEFT_TO_RIGHT,
            bounds: beBounds
        });

        world.play({
            word: playEb,
            proof: m.getProof(words, 6),
            coord: Coord({ x: 8, y: -2 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: ebBounds
        });
    }

    function getBoundsHelper(
        uint16 bound1Positive,
        uint16 bound1Negative,
        uint16 bound2Positive,
        uint16 bound2Negative,
        uint16 bound3Positive,
        uint16 bound3Negative,
        uint16 bound4Positive,
        uint16 bound4Negative,
        uint8 proof1,
        uint8 proof2,
        uint8 proof3,
        uint8 proof4
    )
        public
        view
        returns (Bound[] memory)
    {
        Bound[] memory bounds = new Bound[](4);
        if (bound1Positive != 0 || bound1Negative != 0) {
            bounds[0] = Bound({ positive: bound1Positive, negative: bound1Negative, proof: m.getProof(words, proof1)
});
        }
        if (bound2Positive != 0 || bound2Negative != 0) {
            bounds[1] = Bound({ positive: bound2Positive, negative: bound2Negative, proof: m.getProof(words, proof2)
});
        }
        if (bound3Positive != 0 || bound3Negative != 0) {
            bounds[2] = Bound({ positive: bound3Positive, negative: bound3Negative, proof: m.getProof(words, proof3)
});
        }
        if (bound4Positive != 0 || bound4Negative != 0) {
            bounds[3] = Bound({ positive: bound4Positive, negative: bound4Negative, proof: m.getProof(words, proof4)
});
        }
        return bounds;
    }

    function testFuzz_RevertsWhen_InvalidBounds(
        uint16 bound1Positive,
        uint16 bound1Negative,
        uint16 bound2Positive,
        uint16 bound2Negative,
        uint16 bound3Positive,
        uint16 bound3Negative,
        uint16 bound4Positive,
        uint16 bound4Negative,
        uint8 proof1,
        uint8 proof2,
        uint8 proof3,
        uint8 proof4
    )
        public
    {
        proof1 = uint8(bound(proof1, 0, 9));
        proof2 = uint8(bound(proof2, 0, 9));
        proof3 = uint8(bound(proof3, 0, 9));
        proof4 = uint8(bound(proof4, 0, 9));

        bool areCorrectBounds = false;
        if (
            bound2Positive == 0 && bound2Negative == 1 && proof2 == 7 && bound4Positive == 0 && bound4Negative == 2
                && proof4 == 3 && bound1Positive == 0 && bound1Negative == 0 && bound3Positive == 0 && bound3Negative
== 0
        ) {
            areCorrectBounds = true;
        }
        vm.assume(!areCorrectBounds);

        Letter[] memory playDose = new Letter[](4);
        playDose[0] = Letter.D;
        playDose[1] = Letter.O;
        playDose[2] = Letter.EMPTY;
        playDose[3] = Letter.E;

        Bound[] memory bounds = getBoundsHelper(
            bound1Positive,
            bound1Negative,
            bound2Positive,
            bound2Negative,
            bound3Positive,
            bound3Negative,
            bound4Positive,
            bound4Negative,
            proof1,
            proof2,
            proof3,
            proof4
        );
        bytes32[] memory doseProof = new bytes32[](4);

        vm.expectRevert();
        world.play({
            word: playDose,
            proof: doseProof,
            coord: Coord({ x: 6, y: -1 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: bounds
        });

        // Play dose
        Bound[] memory doseBoundsCorrect = new Bound[](4);
        // Correct bounds
        doseBoundsCorrect[1] = Bound({ positive: 0, negative: 1, proof: m.getProof(words, 7) });
        doseBoundsCorrect[3] = Bound({ positive: 0, negative: 2, proof: m.getProof(words, 3) });
        world.play({
            word: playDose,
            proof: m.getProof(words, 4),
            coord: Coord({ x: 6, y: -1 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: doseBoundsCorrect
        });
    }
}
