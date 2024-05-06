// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import { Direction, Letter } from "codegen/common.sol";
import { Points } from "codegen/index.sol";
import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";
import "forge-std/Test.sol";
import { ClaimSystem } from "systems/ClaimSystem.sol";

contract CrossWord is Words3Test {
    bytes32[] public words;
    Merkle private m;

    function setUp() public override {
        super.setUp();

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

        Letter[] memory bitcraft = new Letter[](8);
        bitcraft[0] = Letter.B;
        bitcraft[1] = Letter.I;
        bitcraft[2] = Letter.T;
        bitcraft[3] = Letter.C;
        bitcraft[4] = Letter.R;
        bitcraft[5] = Letter.A;
        bitcraft[6] = Letter.F;
        bitcraft[7] = Letter.T;

        Letter[] memory ahi = new Letter[](3);
        ahi[0] = Letter.A;
        ahi[1] = Letter.H;
        ahi[2] = Letter.I;

        Letter[] memory tab = new Letter[](3);
        tab[0] = Letter.T;
        tab[1] = Letter.A;
        tab[2] = Letter.B;

        Letter[] memory ta = new Letter[](2);
        ta[0] = Letter.T;
        ta[1] = Letter.A;

        Letter[] memory itcraft = new Letter[](7);
        itcraft[0] = Letter.I;
        itcraft[1] = Letter.T;
        itcraft[2] = Letter.C;
        itcraft[3] = Letter.R;
        itcraft[4] = Letter.A;
        itcraft[5] = Letter.F;
        itcraft[6] = Letter.T;

        Letter[] memory ifWord = new Letter[](2);
        ifWord[0] = Letter.I;
        ifWord[1] = Letter.F;

        Letter[] memory ah = new Letter[](2);
        ah[0] = Letter.A;
        ah[1] = Letter.H;

        words.push(keccak256(bytes.concat(keccak256(abi.encode(craft))))); // craft 0
        words.push(keccak256(bytes.concat(keccak256(abi.encode(aunt))))); // aunt 1
        words.push(keccak256(bytes.concat(keccak256(abi.encode(ifWord))))); // if 2
        words.push(keccak256(bytes.concat(keccak256(abi.encode(bitcraft))))); // bitcraft 3
        words.push(keccak256(bytes.concat(keccak256(abi.encode(ahi))))); // ahi 4
        words.push(keccak256(bytes.concat(keccak256(abi.encode(tab))))); // tab 5
        words.push(keccak256(bytes.concat(keccak256(abi.encode(ta))))); // ta 6
        words.push(keccak256(bytes.concat(keccak256(abi.encode(itcraft))))); // itcraft 7
        words.push(keccak256(bytes.concat(keccak256(abi.encode(ah))))); // ah 8

        setDefaultLetterOdds();
    }

    function test_CrossWordsCraftAunt() public {
        Letter[] memory initialWord = new Letter[](8);
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
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            minPrice: 0.0001 ether,
            wadFactor: 1.3e18,
            wadDurationRoot: 2e18,
            wadDurationScale: 3000e18,
            wadDurationConstant: 0,
            crossWordRewardFraction: 3,
            bonusDistance: 5,
            numDrawLetters: 7
        });

        // Play aunt on the first N
        vm.deal(address(0xface), 50 ether);
        vm.startPrank(address(0xface));
        for (uint256 i = 0; i < 50; i++) {
            vm.roll(block.number + 1000);
            world.draw{ value: 1 ether }(address(0xface));
        }
        Letter[] memory word = new Letter[](4);
        word[0] = Letter.A;
        word[1] = Letter.U;
        word[2] = Letter.EMPTY;
        word[3] = Letter.T;
        Bound[] memory bounds = new Bound[](4);
        bytes32[] memory proof = m.getProof(words, 1);
        world.play(word, proof, Coord({ x: 1, y: -2 }), Direction.TOP_TO_BOTTOM, bounds);
        assertEq(Points.get(address(0xface)), 9);
        assertEq(Points.get(address(0)), 9);

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
        crossWordBounds[3] = Bound({ positive: 0, negative: 1, proof: crossCrossWordProof });
        world.play(crossWord, mainCrossWordProof, Coord({ x: -3, y: 1 }), Direction.LEFT_TO_RIGHT, crossWordBounds);
        assertEq(Points.get(address(0xface)), 31);
        assertEq(Points.get(address(0)), 31);
        vm.stopPrank();

        vm.deal(address(0xffff), 50 ether);
        vm.startPrank(address(0xffff));
        for (uint256 i = 0; i < 50; i++) {
            vm.roll(block.number + 1000);
            world.draw{ value: 1 ether }(address(0xffff));
        }
        // Play it on craft to make itcraft
        Letter[] memory itWord = new Letter[](7);
        itWord[0] = Letter.I;
        itWord[1] = Letter.T;
        itWord[2] = Letter.EMPTY;
        itWord[3] = Letter.EMPTY;
        itWord[4] = Letter.EMPTY;
        itWord[5] = Letter.EMPTY;
        itWord[6] = Letter.EMPTY;
        bytes32[] memory itProof = m.getProof(words, 7);
        Bound[] memory itBounds = new Bound[](7);
        world.play(itWord, itProof, Coord({ x: -5, y: 1 }), Direction.LEFT_TO_RIGHT, itBounds);
        assertEq(Points.get(address(0xffff)), 12);
        assertEq(Points.get(address(0xface)), 35);

        // Play ahi on the i of itcraft
        Letter[] memory ahiWord = new Letter[](3);
        ahiWord[0] = Letter.A;
        ahiWord[1] = Letter.H;
        ahiWord[2] = Letter.EMPTY;

        bytes32[] memory ahiProof = m.getProof(words, 4);
        Bound[] memory ahiBounds = new Bound[](3);

        vm.expectRevert();
        world.play(ahiWord, ahiProof, Coord({ x: -5, y: 1 }), Direction.TOP_TO_BOTTOM, ahiBounds);
        vm.expectRevert();
        world.play(ahiWord, ahiProof, Coord({ x: -5, y: 0 }), Direction.LEFT_TO_RIGHT, ahiBounds);
        world.play(ahiWord, ahiProof, Coord({ x: -5, y: -1 }), Direction.TOP_TO_BOTTOM, ahiBounds);
        vm.stopPrank();
        assertEq(Points.get(address(0xffff)), 41);
        assertEq(Points.get(address(0xface)), 35);

        // play ta
        vm.startPrank(address(0xface));
        Letter[] memory taWord = new Letter[](2);
        taWord[0] = Letter.T;
        taWord[1] = Letter.EMPTY;
        bytes32[] memory taProof = m.getProof(words, 6);
        Bound[] memory taBounds = new Bound[](2);
        world.play(taWord, taProof, Coord({ x: -6, y: -1 }), Direction.LEFT_TO_RIGHT, taBounds);
        assertEq(Points.get(address(0xffff)), 42);
        assertEq(Points.get(address(0xface)), 38);
        vm.stopPrank();

        // Play tab
        vm.startPrank(address(0xface));
        Letter[] memory tabWord = new Letter[](3);
        tabWord[0] = Letter.EMPTY;
        tabWord[1] = Letter.A;
        tabWord[2] = Letter.B;
        bytes32[] memory tabProof = m.getProof(words, 5);
        Bound[] memory tabBounds = new Bound[](3);
        tabBounds[1] = Bound({ positive: 1, negative: 0, proof: m.getProof(words, 8) });
        tabBounds[2] = Bound({ positive: 8, negative: 0, proof: m.getProof(words, 3) });
        vm.expectRevert();
        world.play(tabWord, tabProof, Coord({ x: -6, y: -1 }), Direction.TOP_TO_BOTTOM, tabBounds);
        tabBounds[2] = Bound({ positive: 7, negative: 0, proof: m.getProof(words, 3) });
        world.play(tabWord, tabProof, Coord({ x: -6, y: -1 }), Direction.TOP_TO_BOTTOM, tabBounds);
        // 105
        assertEq(Points.get(address(0xffff)), 64);
        assertEq(Points.get(address(0xface)), 154);
        vm.stopPrank();

        world.donate();
        world.donate{ value: 118 ether }();

        vm.startPrank(address(0xffff));
        world.claim(Points.get(address(0xffff)));
        vm.stopPrank();

        vm.startPrank(address(0xface));
        world.claim(Points.get(address(0xface)));
        vm.stopPrank();

        vm.expectRevert(ClaimSystem.NotEnoughPoints.selector);
        vm.prank(address(0xface));
        world.claim(2);

        vm.expectRevert(ClaimSystem.NotEnoughPoints.selector);
        vm.prank(address(0xffff));
        world.claim(1);

        assertEq(address(0xface).balance, 154 ether);
        assertEq(address(0xffff).balance, 64 ether);
    }
}
