// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";
import {Letter, Direction} from "codegen/Types.sol";
import {MerkleRootConfig, TileLetter, TilePlayer, Points} from "codegen/Tables.sol";

import {Coord} from "common/Coord.sol";
import {Bound} from "common/Bound.sol";
import {GameStartedOrOver} from "common/Errors.sol";

import "forge-std/Test.sol";
import {MudV2Test} from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {Merkle} from "./murky/src/Merkle.sol";

contract PointsTest is MudV2Test {
    IWorld world;
    bytes32[] public words;
    Merkle private m;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
        m = new Merkle();
        Letter[] memory hello = new Letter[](5);
        hello[0] = Letter.H;
        hello[1] = Letter.E;
        hello[1] = Letter.L;
        hello[1] = Letter.L;
        hello[1] = Letter.O;
        Letter[] memory zone = new Letter[](4);
        zone[0] = Letter.Z;
        zone[1] = Letter.O;
        zone[2] = Letter.N;
        zone[3] = Letter.E;
        Letter[] memory zones = new Letter[](5);
        zones[0] = Letter.Z;
        zones[1] = Letter.O;
        zones[2] = Letter.N;
        zones[3] = Letter.E;
        zones[4] = Letter.S;
        words.push(keccak256(bytes.concat(keccak256(abi.encode(hello))))); // hello
        words.push(keccak256(bytes.concat(keccak256(abi.encode(zone))))); // zone
        words.push(keccak256(bytes.concat(keccak256(abi.encode(zones))))); // zones
    }

    function testCountPoints() public {
        address player1 = address(0x12345);
        address player2 = address(0x22345);

        Letter[] memory initialWord = new Letter[](5);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.E;
        initialWord[2] = Letter.L;
        initialWord[3] = Letter.L;
        initialWord[4] = Letter.O;

        world.start(initialWord, 10, m.getRoot(words), 0, 0, 0, 3);

        Letter[] memory word = new Letter[](4);
        word[0] = Letter.Z;
        word[1] = Letter.EMPTY;
        word[2] = Letter.N;
        word[3] = Letter.E;

        Bound[] memory bounds = new Bound[](4);
        bytes32[] memory proof = m.getProof(words, 1);

        // Play zone
        vm.prank(player1);
        world.play(word, proof, Coord({x: 4, y: -1}), Direction.TOP_TO_BOTTOM, bounds);
        assertEq(Points.get(world, player1), 13);

        // Play zones
        Letter[] memory ext = new Letter[](5);
        ext[0] = Letter.EMPTY;
        ext[1] = Letter.EMPTY;
        ext[2] = Letter.EMPTY;
        ext[3] = Letter.EMPTY;
        ext[4] = Letter.S;
        Bound[] memory extBounds = new Bound[](5);
        bytes32[] memory extProof = m.getProof(words, 2);
        vm.prank(player2);
        world.play(ext, extProof, Coord({x: 4, y: -1}), Direction.TOP_TO_BOTTOM, extBounds);
        assertEq(Points.get(world, player2), 14);
        // We lose 1 because of rounding
        assertEq(Points.get(world, player1), 13 + 3);
    }
}
