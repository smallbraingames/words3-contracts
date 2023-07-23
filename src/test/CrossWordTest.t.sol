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

contract CrossWordTest is MudV2Test {
    IWorld world;
    bytes32[] public words;
    Merkle private m;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);

        m = new Merkle();
        Letter[] memory craft = new Letter[](5);

        craft[0] = Letter.C;
        craft[1] = Letter.R;
        craft[2] = Letter.A;
        craft[3] = Letter.F;
        craft[4] = Letter.T;

        Letter[] memory aunt = new Letter[](4);
        aunt[0] = Letter.A;
        aunt[1] = Letter.U;
        aunt[2] = Letter.N;
        aunt[3] = Letter.T;

        Letter[] memory ifWord = new Letter[](2);
        ifWord[0] = Letter.I;
        ifWord[1] = Letter.F;

        words.push(keccak256(bytes.concat(keccak256(abi.encode(craft))))); // craft
        words.push(keccak256(bytes.concat(keccak256(abi.encode(aunt))))); // aunt
        words.push(keccak256(bytes.concat(keccak256(abi.encode(ifWord))))); // if
    }

    function testCrossWordsCraftAunt() public {
        Letter[] memory initialWord = new Letter[](8);
        initialWord[0] = Letter.I;
        initialWord[1] = Letter.N;
        initialWord[2] = Letter.F;
        initialWord[3] = Letter.I;
        initialWord[4] = Letter.N;
        initialWord[5] = Letter.I;
        initialWord[6] = Letter.T;
        initialWord[7] = Letter.E;
        world.start(initialWord, 10, m.getRoot(words), 0, 0, 0, 3);

        // Play aunt on the first N
        Letter[] memory word = new Letter[](4);
        word[0] = Letter.A;
        word[1] = Letter.U;
        word[2] = Letter.EMPTY;
        word[3] = Letter.T;
        Bound[] memory bounds = new Bound[](4);
        bytes32[] memory proof = m.getProof(words, 1);
        world.play(word, proof, Coord({x: 1, y: -2}), Direction.TOP_TO_BOTTOM, bounds);

        // Now play craft using the t from aunt, and making an if cross word
        Letter[] memory crossWord = new Letter[](5);
        crossWord[0] = Letter.C;
        crossWord[1] = Letter.R;
        crossWord[2] = Letter.A;
        crossWord[3] = Letter.F;
        crossWord[4] = Letter.EMPTY;
        bytes32[] memory mainCrossWordProof = m.getProof(words, 0);
        bytes32[] memory crossCrossWordProof = m.getProof(words, 2);
        Bound[] memory crossWordBounds = new Bound[](5);
        crossWordBounds[3] = Bound({positive: 0, negative: 1, proof: crossCrossWordProof});
        world.play(crossWord, mainCrossWordProof, Coord({x: -3, y: 1}), Direction.LEFT_TO_RIGHT, crossWordBounds);
    }
}
