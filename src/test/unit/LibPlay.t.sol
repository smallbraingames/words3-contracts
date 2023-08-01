// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";
import {Letter, Direction} from "codegen/Types.sol";
import {TileLetter, TilePlayer, MerkleRootConfig} from "codegen/Tables.sol";

import {Bound} from "common/Bound.sol";
import {Coord} from "common/Coord.sol";
import {LibPlay} from "libraries/LibPlay.sol";
import {LibBoard} from "libraries/LibBoard.sol";
import {
    WordTooLong,
    InvalidWordStart,
    InvalidWordEnd,
    EmptyLetterNotOnExistingLetter,
    LetterOnExistingLetter,
    LonelyWord,
    NoLettersPlayed,
    WordNotInDictionary,
    InvalidBoundLength,
    NonzeroEmptyLetterBound,
    NonemptyBoundEdges
} from "common/Errors.sol";

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";
import {Merkle} from "../murky/src/Merkle.sol";
import {Wrapper} from "./Wrapper.sol";

contract LibPlayTest is MudTest {
    IWorld world;
    bytes32[] public words;
    Merkle private m;
    Wrapper wrapper;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
        wrapper = new Wrapper();

        m = new Merkle();
        // The words lap and ice are in the merkle tree
        Letter[] memory lap = new Letter[](3);
        lap[0] = Letter.L;
        lap[1] = Letter.A;
        lap[2] = Letter.P;

        Letter[] memory ice = new Letter[](3);
        ice[0] = Letter.I;
        ice[1] = Letter.C;
        ice[2] = Letter.E;

        // Make IC a word for testing
        Letter[] memory ic = new Letter[](2);
        ic[0] = Letter.I;
        ic[1] = Letter.C;

        words.push(keccak256(bytes.concat(keccak256(abi.encode(lap))))); // lap
        words.push(keccak256(bytes.concat(keccak256(abi.encode(ice))))); // ice
        words.push(keccak256(bytes.concat(keccak256(abi.encode(ic))))); // ic
    }

    function testSetTiles() public {
        vm.startPrank(worldAddress);
        TileLetter.set(0, 0, Letter.E);
        TilePlayer.set(0, 0, address(0x123));
        Letter[] memory word = new Letter[](4);
        word[0] = Letter.T;
        word[1] = Letter.EMPTY;
        word[2] = Letter.S;
        word[3] = Letter.T;
        Letter[] memory filledWord =
            LibPlay.setTiles(word, Coord({x: -1, y: 0}), Direction.LEFT_TO_RIGHT, address(this));
        vm.stopPrank();
        assertEq(uint8(TileLetter.get(-1, 0)), uint8(Letter.T));
        assertEq(uint8(TileLetter.get(0, 0)), uint8(Letter.E));
        assertEq(uint8(TileLetter.get(1, 0)), uint8(Letter.S));
        assertEq(uint8(TileLetter.get(2, 0)), uint8(Letter.T));
        assertEq(uint8(filledWord[0]), uint8(Letter.T));
        assertEq(uint8(filledWord[1]), uint8(Letter.E));
        assertEq(uint8(filledWord[2]), uint8(Letter.S));
        assertEq(uint8(filledWord[3]), uint8(Letter.T));
        assertEq(TilePlayer.get(-1, 0), address(this));
        assertEq(TilePlayer.get(0, 0), address(0x123));
        assertEq(TilePlayer.get(1, 0), address(this));
        assertEq(TilePlayer.get(2, 0), address(this));
        assertEq(uint8(word[1]), uint8(Letter.EMPTY));
    }

    /// forge-config: default.fuzz.runs = 256
    function testFuzzSetTiles(
        uint8[] memory wordRaw,
        bool directionRightToLeft,
        int32 startX,
        int32 startY,
        address player,
        uint8 fill
    ) public {
        vm.assume(startX >= -1e9 && startX <= 1e9);
        vm.assume(startY >= -1e9 && startY <= 1e9);
        fill = uint8(bound(fill, 1, 26));
        Coord memory startCoord = Coord({x: startX, y: startY});
        vm.startPrank(worldAddress);
        Direction direction = directionRightToLeft ? Direction.LEFT_TO_RIGHT : Direction.TOP_TO_BOTTOM;
        Letter[] memory word = new Letter[](wordRaw.length);
        Letter[] memory expectedFilledWord = new Letter[](wordRaw.length);
        for (uint256 i = 0; i < wordRaw.length; i++) {
            word[i] = Letter(bound(wordRaw[i], 0, 26));
            if (word[i] == Letter.EMPTY) {
                Coord memory coord = LibBoard.getRelativeCoord(startCoord, int32(uint32(i)), direction);
                TileLetter.set(coord.x, coord.y, Letter(fill));
                TilePlayer.set(coord.x, coord.y, address(this));
                expectedFilledWord[i] = Letter(fill);
            } else {
                expectedFilledWord[i] = word[i];
            }
        }
        Letter[] memory filledWord = LibPlay.setTiles(word, startCoord, direction, player);
        vm.stopPrank();
        assertEq(abi.encode(filledWord), abi.encode(expectedFilledWord));
        for (uint256 i = 0; i < wordRaw.length; i++) {
            assertEq(uint8(word[i]), uint8(bound(wordRaw[i], 0, 26)));
            Coord memory coord = LibBoard.getRelativeCoord(startCoord, int32(uint32(i)), direction);
            assertEq(uint8(TileLetter.get(coord.x, coord.y)), uint8(expectedFilledWord[i]));
            if (word[i] == Letter.EMPTY) {
                assertEq(TilePlayer.get(coord.x, coord.y), address(this));
            } else {
                assertEq(TilePlayer.get(coord.x, coord.y), player);
            }
        }
    }

    function testCheckCrossWords() public {
        address directlyBuildsOn = address(0x321);
        address buildsOnA = address(0xface);
        address buildsOnB = address(0xcafe);
        address buildsOnC = address(0xdead);
        Letter[] memory word = new Letter[](5);
        word[0] = Letter.EMPTY; // (0, 0)
        word[1] = Letter.U; // (1, 0)
        word[2] = Letter.A; // (2, 0)
        word[3] = Letter.C; // (3, 0)
        word[4] = Letter.K; // (4, 0)
        Direction direction = Direction.LEFT_TO_RIGHT;
        vm.startPrank(worldAddress);
        // Q, which is directly built on
        TileLetter.set(0, 0, Letter.Q);
        TilePlayer.set(0, 0, directlyBuildsOn);
        // LAP, made by one player
        TileLetter.set(2, -1, Letter.L);
        TileLetter.set(2, 1, Letter.P);
        TilePlayer.set(2, -1, buildsOnA);
        TilePlayer.set(2, 1, buildsOnA);
        // ICE, made by two players
        TileLetter.set(3, -1, Letter.I);
        TilePlayer.set(3, -1, buildsOnB);
        TileLetter.set(3, 1, Letter.E);
        TilePlayer.set(3, 1, buildsOnC);
        MerkleRootConfig.set(m.getRoot(words));
        vm.stopPrank();
        Bound[] memory boundsInvalid = new Bound[](6);
        bytes32[] memory emptyProof = new bytes32[](1);
        bytes32[] memory lapProof = m.getProof(words, 0);
        bytes32[] memory iceProof = m.getProof(words, 1);
        boundsInvalid[0] = Bound({positive: 0, negative: 0, proof: emptyProof});
        boundsInvalid[1] = Bound({positive: 0, negative: 0, proof: emptyProof});
        boundsInvalid[2] = Bound({positive: 1, negative: 1, proof: lapProof});
        boundsInvalid[3] = Bound({positive: 1, negative: 1, proof: iceProof});
        boundsInvalid[4] = Bound({positive: 0, negative: 0, proof: emptyProof});
        boundsInvalid[5] = Bound({positive: 0, negative: 0, proof: emptyProof});
        vm.expectRevert();
        wrapper.playCheckCrossWords(word, Coord({x: 0, y: 0}), direction, boundsInvalid);

        Bound[] memory boundsInvalidTwo = new Bound[](5);
        boundsInvalidTwo[0] = Bound({positive: 0, negative: 0, proof: emptyProof});
        boundsInvalidTwo[1] = Bound({positive: 0, negative: 0, proof: emptyProof});
        boundsInvalidTwo[2] = Bound({positive: 1, negative: 1, proof: lapProof});
        boundsInvalidTwo[3] = Bound({positive: 1, negative: 1, proof: iceProof});
        boundsInvalidTwo[4] = Bound({positive: 100, negative: 300, proof: emptyProof});

        vm.expectRevert();
        wrapper.playCheckCrossWords(word, Coord({x: 0, y: 0}), direction, boundsInvalidTwo);

        boundsInvalidTwo[4] = Bound({positive: 1, negative: 1, proof: emptyProof});
        vm.expectRevert();
        wrapper.playCheckCrossWords(word, Coord({x: 0, y: 0}), direction, boundsInvalidTwo);

        boundsInvalidTwo[4] = Bound({positive: 0, negative: 0, proof: emptyProof});
        boundsInvalidTwo[3] = Bound({positive: 0, negative: 1, proof: m.getProof(words, 2)});
        vm.expectRevert();
        wrapper.playCheckCrossWords(word, Coord({x: 0, y: 0}), direction, boundsInvalidTwo);

        boundsInvalidTwo[3] = Bound({positive: 1, negative: 1, proof: m.getProof(words, 2)});
        vm.expectRevert();
        wrapper.playCheckCrossWords(word, Coord({x: 0, y: 9000}), direction, boundsInvalidTwo);

        boundsInvalidTwo[3] = Bound({positive: 1, negative: 1, proof: m.getProof(words, 1)});
        // Does not revert
        address[] memory buildsOnPlayers =
            LibPlay.checkCrossWords(word, Coord({x: 0, y: 0}), direction, boundsInvalidTwo);
        assertEq(buildsOnPlayers.length, 5);
        assertEq(buildsOnPlayers[0], directlyBuildsOn);
        assertEq(buildsOnPlayers[1], buildsOnA);
        assertEq(buildsOnPlayers[2], buildsOnA);
        assertEq(buildsOnPlayers[3], buildsOnC);
        assertEq(buildsOnPlayers[4], buildsOnB);
    }
}
