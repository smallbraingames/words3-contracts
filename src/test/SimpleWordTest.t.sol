// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";
import {Letter, Direction} from "codegen/Types.sol";
import {MerkleRootConfig, TileLetter, TilePlayer} from "codegen/Tables.sol";

import {Coord} from "common/Coord.sol";
import {Bound} from "common/Bound.sol";
import {GameStartedOrOver} from "common/Errors.sol";

import "forge-std/Test.sol";
import {MudV2Test} from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {Merkle} from "./murky/src/Merkle.sol";

contract SimpleWordTest is MudV2Test {
    IWorld world;
    bytes32[] public words;
    Merkle private m;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);

        m = new Merkle();
        Letter[] memory hi = new Letter[](2);
        hi[0] = Letter.H;
        hi[1] = Letter.I;
        Letter[] memory go = new Letter[](2);
        go[0] = Letter.G;
        go[1] = Letter.O;
        words.push(keccak256(bytes.concat(keccak256(abi.encode(hi))))); // hi
        words.push(keccak256(bytes.concat(keccak256(abi.encode(go))))); // go
    }

    function testSetup() public {
        Letter[] memory initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;
        world.start(initialWord, 10, m.getRoot(words), 0, 0, 0, 3);
        assertEq(uint8(TileLetter.get(world, 0, 0)), uint8(Letter.H));
        assertEq(uint8(TileLetter.get(world, 1, 0)), uint8(Letter.I));
    }

    function testPlayHi() public {
        Letter[] memory initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;
        world.start(initialWord, 10, m.getRoot(words), 0, 0, 0, 3);

        Letter[] memory word = new Letter[](2);
        word[0] = Letter.EMPTY;
        word[1] = Letter.I;
        Bound[] memory bounds = new Bound[](2);
        bytes32[] memory proof = m.getProof(words, 0);

        world.play(word, proof, Coord({x: 0, y: 0}), Direction.TOP_TO_BOTTOM, bounds);
    }
}