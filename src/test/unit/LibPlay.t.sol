// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Direction, Letter } from "codegen/common.sol";
import { GameConfig, MerkleRootConfig, Points, TileLetter, TilePlayer } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";

import {
    EmptyLetterNotOnExistingLetter,
    InvalidBoundLength,
    InvalidWordEnd,
    InvalidWordStart,
    LetterOnExistingLetter,
    LonelyWord,
    NoLettersPlayed,
    NonemptyBoundEdges,
    NonzeroEmptyLetterBound,
    WordNotInDictionary,
    WordTooLong
} from "common/Errors.sol";
import { LibBoard } from "libraries/LibBoard.sol";
import { LibPlay } from "libraries/LibPlay.sol";
import { LibPoints } from "libraries/LibPoints.sol";

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import { Wrapper } from "./Wrapper.sol";
import "forge-std/Test.sol";

contract LibPlayTest is Words3Test {
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
        vm.startPrank(deployerAddress);
        TileLetter.set(0, 0, Letter.E);
        TilePlayer.set(0, 0, address(0x123));
        Letter[] memory word = new Letter[](4);
        word[0] = Letter.T;
        word[1] = Letter.EMPTY;
        word[2] = Letter.S;
        word[3] = Letter.T;
        Letter[] memory filledWord =
            LibPlay.setTiles(word, Coord({ x: -1, y: 0 }), Direction.LEFT_TO_RIGHT, address(this));
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
    )
        public
    {
        vm.assume(startX >= -1e9 && startX <= 1e9);
        vm.assume(startY >= -1e9 && startY <= 1e9);
        fill = uint8(bound(fill, 1, 26));
        Coord memory startCoord = Coord({ x: startX, y: startY });
        vm.startPrank(deployerAddress);
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

    function testFuzzCheckCrossWordsBuildsOnPlayers(
        int32 startX,
        int32 startY,
        uint8[] memory wordRaw,
        uint32 points
    )
        public
    {
        vm.assume(startX >= -1e9 && startX <= 1e9);
        vm.assume(startY >= -1e9 && startY <= 1e9);
        vm.assume(wordRaw.length <= 40);
        vm.assume(wordRaw.length > 0);
        Coord memory startCoord = Coord({ x: startX, y: startY });
        Letter[] memory word = new Letter[](wordRaw.length);
        for (uint256 i = 0; i < wordRaw.length; i++) {
            word[i] = Letter(bound(wordRaw[i], 1, 26));
        }
        address topPlayer = address(0x123);
        address leftPlayer = address(0x321);
        vm.startPrank(deployerAddress);
        words.push(keccak256(bytes.concat(keccak256(abi.encode(word)))));
        MerkleRootConfig.set(m.getRoot(words));
        for (uint256 i = 1; i < word.length; i++) {
            Coord memory coord = LibBoard.getRelativeCoord(startCoord, int32(uint32(i)), Direction.LEFT_TO_RIGHT);
            TileLetter.set(coord.x, coord.y, word[i]);
            TilePlayer.set(coord.x, coord.y, topPlayer);
            coord = LibBoard.getRelativeCoord(startCoord, int32(uint32(i)), Direction.TOP_TO_BOTTOM);
            TileLetter.set(coord.x, coord.y, word[i]);
            TilePlayer.set(coord.x, coord.y, leftPlayer);
        }
        vm.stopPrank();
        Bound[] memory bounds = new Bound[](word.length);
        bounds[0] =
            Bound({ positive: uint16(word.length) - 1, negative: 0, proof: m.getProof(words, words.length - 1) });
        for (uint256 i = 1; i < word.length; i++) {
            word[i] = Letter.EMPTY;
        }
        address[] memory l2r = LibPlay.checkCrossWords(word, startCoord, Direction.LEFT_TO_RIGHT, bounds);
        address[] memory t2b = LibPlay.checkCrossWords(word, startCoord, Direction.TOP_TO_BOTTOM, bounds);
        uint32 p1pointsl2r;
        uint32 p2pointsl2r;
        uint32 p1pointst2b;
        uint32 p2pointst2b;
        vm.startPrank(deployerAddress);
        GameConfig.setCrossWordRewardFraction(3);
        LibPoints.setBuildsOnWordRewards(points, l2r, 1);
        p1pointsl2r = Points.get(topPlayer);
        p2pointsl2r = Points.get(leftPlayer);
        Points.set(topPlayer, 0);
        Points.set(leftPlayer, 0);
        LibPoints.setBuildsOnWordRewards(points, t2b, 2);
        p1pointst2b = Points.get(topPlayer);
        p2pointst2b = Points.get(leftPlayer);
        vm.stopPrank();
        assertEq(p1pointsl2r, p1pointst2b);
        assertEq(p2pointsl2r, p2pointst2b);
    }

    function testFuzzCheckCrossWords(int32 startX, int32 startY, bool directionRightToLeft) public {
        vm.assume(startX >= -1e9 && startX <= 1e9);
        vm.assume(startY >= -1e9 && startY <= 1e9);
        Coord memory startCoord = Coord({ x: startX, y: startY });
        Direction direction = directionRightToLeft ? Direction.LEFT_TO_RIGHT : Direction.TOP_TO_BOTTOM;

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
        vm.startPrank(deployerAddress);
        // Q, which is directly built on
        TileLetter.set(startX, startY, Letter.Q);
        TilePlayer.set(startX, startY, directlyBuildsOn);
        // LAP, made by one player
        TileLetter.set(
            direction == Direction.LEFT_TO_RIGHT ? startX + 2 : startX - 1,
            direction == Direction.LEFT_TO_RIGHT ? startY - 1 : startY + 2,
            Letter.L
        );
        TileLetter.set(
            direction == Direction.LEFT_TO_RIGHT ? startX + 2 : startX + 1,
            direction == Direction.LEFT_TO_RIGHT ? startY + 1 : startY + 2,
            Letter.P
        );
        TilePlayer.set(
            direction == Direction.LEFT_TO_RIGHT ? startX + 2 : startX - 1,
            direction == Direction.LEFT_TO_RIGHT ? startY - 1 : startY + 2,
            buildsOnA
        );
        TilePlayer.set(
            direction == Direction.LEFT_TO_RIGHT ? startX + 2 : startX + 1,
            direction == Direction.LEFT_TO_RIGHT ? startY + 1 : startY + 2,
            buildsOnA
        );
        // ICE, made by two players
        TileLetter.set(
            direction == Direction.LEFT_TO_RIGHT ? startX + 3 : startX - 1,
            direction == Direction.LEFT_TO_RIGHT ? startY - 1 : startY + 3,
            Letter.I
        );
        TilePlayer.set(
            direction == Direction.LEFT_TO_RIGHT ? startX + 3 : startX - 1,
            direction == Direction.LEFT_TO_RIGHT ? startY - 1 : startY + 3,
            buildsOnB
        );
        TileLetter.set(
            direction == Direction.LEFT_TO_RIGHT ? startX + 3 : startX + 1,
            direction == Direction.LEFT_TO_RIGHT ? startY + 1 : startY + 3,
            Letter.E
        );
        TilePlayer.set(
            direction == Direction.LEFT_TO_RIGHT ? startX + 3 : startX + 1,
            direction == Direction.LEFT_TO_RIGHT ? startY + 1 : startY + 3,
            buildsOnC
        );
        MerkleRootConfig.set(m.getRoot(words));
        vm.stopPrank();
        Bound[] memory boundsInvalid = new Bound[](6);
        bytes32[] memory emptyProof = new bytes32[](1);
        bytes32[] memory lapProof = m.getProof(words, 0);
        bytes32[] memory iceProof = m.getProof(words, 1);
        boundsInvalid[0] = Bound({ positive: 0, negative: 0, proof: emptyProof });
        boundsInvalid[1] = Bound({ positive: 0, negative: 0, proof: emptyProof });
        boundsInvalid[2] = Bound({ positive: 1, negative: 1, proof: lapProof });
        boundsInvalid[3] = Bound({ positive: 1, negative: 1, proof: iceProof });
        boundsInvalid[4] = Bound({ positive: 0, negative: 0, proof: emptyProof });
        boundsInvalid[5] = Bound({ positive: 0, negative: 0, proof: emptyProof });
        vm.expectRevert();
        wrapper.playCheckCrossWords(word, startCoord, direction, boundsInvalid);

        Bound[] memory boundsInvalidTwo = new Bound[](5);
        boundsInvalidTwo[0] = Bound({ positive: 0, negative: 0, proof: emptyProof });
        boundsInvalidTwo[1] = Bound({ positive: 0, negative: 0, proof: emptyProof });
        boundsInvalidTwo[2] = Bound({ positive: 1, negative: 1, proof: lapProof });
        boundsInvalidTwo[3] = Bound({ positive: 1, negative: 1, proof: iceProof });
        boundsInvalidTwo[4] = Bound({ positive: 100, negative: 300, proof: emptyProof });

        vm.expectRevert();
        wrapper.playCheckCrossWords(word, startCoord, direction, boundsInvalidTwo);

        boundsInvalidTwo[4] = Bound({ positive: 1, negative: 1, proof: emptyProof });
        vm.expectRevert();
        wrapper.playCheckCrossWords(word, startCoord, direction, boundsInvalidTwo);

        boundsInvalidTwo[4] = Bound({ positive: 0, negative: 0, proof: emptyProof });
        boundsInvalidTwo[3] = Bound({ positive: 0, negative: 1, proof: m.getProof(words, 2) });
        vm.expectRevert();
        wrapper.playCheckCrossWords(word, startCoord, direction, boundsInvalidTwo);

        boundsInvalidTwo[3] = Bound({ positive: 1, negative: 1, proof: m.getProof(words, 2) });
        vm.expectRevert();
        wrapper.playCheckCrossWords(word, startCoord, direction, boundsInvalidTwo);

        boundsInvalidTwo[3] = Bound({ positive: 1, negative: 1, proof: m.getProof(words, 1) });
        // Does not revert
        address[] memory buildsOnPlayers = LibPlay.checkCrossWords(word, startCoord, direction, boundsInvalidTwo);
        assertEq(buildsOnPlayers.length, 5);
        assertEq(buildsOnPlayers[0], directlyBuildsOn);
        assertEq(buildsOnPlayers[1], buildsOnA);
        assertEq(buildsOnPlayers[2], buildsOnA);
        assertEq(buildsOnPlayers[3], buildsOnC);
        assertEq(buildsOnPlayers[4], buildsOnB);
    }

    function testStripZeroAddresses() public {
        address[] memory addresses = new address[](5);
        addresses[0] = address(0x0);
        addresses[1] = address(0x1);
        addresses[2] = address(0x2);
        addresses[3] = address(0x3);
        addresses[4] = address(0x4);
        address[] memory stripped = LibPlay.stripZeroAddresses(addresses);
        assertEq(stripped.length, 4);
        assertEq(stripped[0], address(0x1));
        assertEq(stripped[1], address(0x2));
        assertEq(stripped[2], address(0x3));
        assertEq(stripped[3], address(0x4));

        addresses[0] = address(0x0);
        addresses[1] = address(0x0);
        addresses[2] = address(0x0);
        addresses[3] = address(0x0);
        addresses[4] = address(0x0);
        stripped = LibPlay.stripZeroAddresses(addresses);
        assertEq(stripped.length, 0);

        addresses[0] = address(0x0);
        addresses[1] = address(0x1);
        addresses[2] = address(0x0);
        addresses[3] = address(0x3);
        addresses[4] = address(0x0);
        stripped = LibPlay.stripZeroAddresses(addresses);
        assertEq(stripped.length, 2);
        assertEq(stripped[0], address(0x1));
        assertEq(stripped[1], address(0x3));
    }

    function testCheckWord() public {
        Letter[] memory word = new Letter[](3);
        word[0] = Letter.EMPTY;
        word[1] = Letter.C;
        word[2] = Letter.E;

        vm.startPrank(deployerAddress);
        TileLetter.set(0, 0, Letter.I);
        MerkleRootConfig.set(m.getRoot(words));
        vm.stopPrank();

        bytes32[] memory iceProof = m.getProof(words, 1);
        vm.expectRevert();
        wrapper.playCheckWord(word, iceProof, Coord({ x: 1, y: 0 }), Direction.LEFT_TO_RIGHT);
        vm.expectRevert();
        wrapper.playCheckWord(word, iceProof, Coord({ x: -1, y: 0 }), Direction.LEFT_TO_RIGHT);
        vm.expectRevert();
        wrapper.playCheckWord(word, iceProof, Coord({ x: 0, y: 1 }), Direction.TOP_TO_BOTTOM);

        word[0] = Letter.I;
        vm.expectRevert();
        wrapper.playCheckWord(word, iceProof, Coord({ x: 3, y: 3 }), Direction.LEFT_TO_RIGHT);

        Letter[] memory emptyWord = new Letter[](1);
        emptyWord[0] = Letter.EMPTY;
        bytes32[] memory emptyProof = new bytes32[](1);
        emptyProof[0] = bytes32(0x0);
        vm.expectRevert();
        wrapper.playCheckWord(emptyWord, emptyProof, Coord({ x: 0, y: 0 }), Direction.LEFT_TO_RIGHT);
        vm.expectRevert();
        wrapper.playCheckWord(emptyWord, emptyProof, Coord({ x: 0, y: 0 }), Direction.TOP_TO_BOTTOM);

        word[0] = Letter.EMPTY;
        LibPlay.checkWord(word, iceProof, Coord({ x: 0, y: 0 }), Direction.LEFT_TO_RIGHT);
        LibPlay.checkWord(word, iceProof, Coord({ x: 0, y: 0 }), Direction.TOP_TO_BOTTOM);
    }

    function testFuzzRevertCheckWord(
        int32 startX,
        int32 startY,
        uint8[] memory wordRaw,
        bytes32[] memory proof,
        bool direction
    )
        public
    {
        Letter[] memory word = new Letter[](wordRaw.length);
        for (uint256 i = 0; i < word.length; i++) {
            word[i] = Letter(uint8(bound(wordRaw[i], 0, 26)));
        }
        Direction dir = direction ? Direction.LEFT_TO_RIGHT : Direction.TOP_TO_BOTTOM;
        vm.expectRevert();
        wrapper.playCheckWord(word, proof, Coord({ x: startX, y: startY }), dir);

        vm.startPrank(deployerAddress);
        MerkleRootConfig.set(m.getRoot(words));
        vm.stopPrank();
        bytes32[] memory iceProof = m.getProof(words, 1);
        vm.expectRevert();
        Letter[] memory ice = new Letter[](3);
        ice[0] = Letter.I;
        ice[1] = Letter.C;
        ice[2] = Letter.E;
        wrapper.playCheckWord(ice, iceProof, Coord({ x: startX, y: startY }), dir);
    }
}
