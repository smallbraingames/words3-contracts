// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import { Direction, Letter } from "codegen/common.sol";
import { FeeConfigData, Points, PriceConfigData } from "codegen/index.sol";
import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";
import "forge-std/Test.sol";

contract CrossWordNoEmpty is Words3Test {
    bytes32[] public words;
    Merkle private m;
    address private player1 = address(0xcafe);
    address private player2 = address(0xbabe);

    function setUp() public override {
        super.setUp();

        m = new Merkle();

        Letter[] memory jobe = new Letter[](4);
        jobe[0] = Letter.J;
        jobe[1] = Letter.O;
        jobe[2] = Letter.B;
        jobe[3] = Letter.E;

        Letter[] memory join = new Letter[](4);
        join[0] = Letter.J;
        join[1] = Letter.O;
        join[2] = Letter.I;
        join[3] = Letter.N;

        // Spelled wrong for testing purposes
        Letter[] memory colaborate = new Letter[](10);
        colaborate[0] = Letter.C;
        colaborate[1] = Letter.O;
        colaborate[2] = Letter.L;
        colaborate[3] = Letter.A;
        colaborate[4] = Letter.B;
        colaborate[5] = Letter.O;
        colaborate[6] = Letter.R;
        colaborate[7] = Letter.A;
        colaborate[8] = Letter.T;
        colaborate[9] = Letter.E;

        Letter[] memory ol = new Letter[](2);
        ol[0] = Letter.O;
        ol[1] = Letter.L;

        Letter[] memory eb = new Letter[](2);
        eb[0] = Letter.E;
        eb[1] = Letter.B;

        Letter[] memory coins = new Letter[](5);
        coins[0] = Letter.C;
        coins[1] = Letter.O;
        coins[2] = Letter.I;
        coins[3] = Letter.N;
        coins[4] = Letter.S;

        Letter[] memory joins = new Letter[](5);
        joins[0] = Letter.J;
        joins[1] = Letter.O;
        joins[2] = Letter.I;
        joins[3] = Letter.N;
        joins[4] = Letter.S;

        words.push(keccak256(bytes.concat(keccak256(abi.encode(jobe))))); // jobe 0
        words.push(keccak256(bytes.concat(keccak256(abi.encode(join))))); // join 1
        words.push(keccak256(bytes.concat(keccak256(abi.encode(colaborate))))); // colaborate 2
        words.push(keccak256(bytes.concat(keccak256(abi.encode(ol))))); // ol 3
        words.push(keccak256(bytes.concat(keccak256(abi.encode(eb))))); // eb 4
        words.push(keccak256(bytes.concat(keccak256(abi.encode(coins))))); // coins 5
        words.push(keccak256(bytes.concat(keccak256(abi.encode(joins))))); // joins 6

        setDefaultLetterOdds();

        uint32[26] memory initialLetterAllocation;
        for (uint8 i = 0; i < 26; i++) {
            initialLetterAllocation[i] = 100;
        }

        Letter[] memory initialWord = new Letter[](5);
        initialWord[0] = Letter.B;
        initialWord[1] = Letter.A;
        initialWord[2] = Letter.T;
        initialWord[3] = Letter.E;
        initialWord[4] = Letter.S;

        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: player1,
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.0001 ether,
                wadFactor: 1.3e18,
                wadDurationRoot: 2e18,
                wadDurationScale: 3000e18,
                wadDurationConstant: 0
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 3,
            numDrawLetters: 7
        });

        Letter[] memory lettersToTransfer = new Letter[](26 * 50);
        for (uint32 i = 1; i < 27; i++) {
            for (uint32 j = 0; j < 50; j++) {
                lettersToTransfer[(i - 1) * 50 + j] = Letter(i);
            }
        }
        vm.prank(player1);
        world.transfer({ letters: lettersToTransfer, to: player2 });

        // play jobe
        vm.startPrank(player1);
        Letter[] memory playJobe = new Letter[](4);
        playJobe[0] = Letter.J;
        playJobe[1] = Letter.O;
        playJobe[2] = Letter.EMPTY;
        playJobe[3] = Letter.E;
        Bound[] memory jobeBounds = new Bound[](4);
        world.play({
            word: playJobe,
            proof: m.getProof(words, 0),
            coord: Coord({ x: -2, y: -2 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: jobeBounds
        });
        vm.stopPrank();
        assertEq(Points.get({ player: player1 }), 16);
        assertEq(Points.get({ player: player2 }), 0);
        assertEq(Points.get({ player: address(0) }), 16);

        // play join
        vm.startPrank(player2);
        Letter[] memory playJoin = new Letter[](4);
        playJoin[0] = Letter.EMPTY;
        playJoin[1] = Letter.O;
        playJoin[2] = Letter.I;
        playJoin[3] = Letter.N;
        Bound[] memory joinBounds = new Bound[](4);
        world.play({
            word: playJoin,
            proof: m.getProof(words, 1),
            coord: Coord({ x: -2, y: -2 }),
            direction: Direction.LEFT_TO_RIGHT,
            bounds: joinBounds
        });
        vm.stopPrank();
        assertEq(Points.get({ player: player1 }), 21);
        assertEq(Points.get({ player: player2 }), 15);
        assertEq(Points.get({ player: address(0) }), 36);

        // Play colaborate
        vm.startPrank(player1);
        Letter[] memory playColaborate = new Letter[](10);
        playColaborate[0] = Letter.C;
        playColaborate[1] = Letter.EMPTY;
        playColaborate[2] = Letter.L;
        playColaborate[3] = Letter.EMPTY;
        playColaborate[4] = Letter.B;
        playColaborate[5] = Letter.O;
        playColaborate[6] = Letter.R;
        playColaborate[7] = Letter.A;
        playColaborate[8] = Letter.T;
        playColaborate[9] = Letter.E;
        Bound[] memory colaborateBounds = new Bound[](10);
        colaborateBounds[2] = Bound({ positive: 0, negative: 1, proof: m.getProof(words, 3) });
        colaborateBounds[4] = Bound({ positive: 0, negative: 1, proof: m.getProof(words, 4) });
        world.play({
            word: playColaborate,
            proof: m.getProof(words, 2),
            coord: Coord({ x: -1, y: -3 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: colaborateBounds
        });
        vm.stopPrank();
        assertEq(Points.get({ player: player1 }), 49);
        assertEq(Points.get({ player: player2 }), 17);
        assertEq(Points.get({ player: address(0) }), 66);
    }

    function test_CrossWordNoEmpty() public {
        vm.startPrank(player2);
        Letter[] memory playCoins = new Letter[](5);
        playCoins[0] = Letter.C;
        playCoins[1] = Letter.O;
        playCoins[2] = Letter.I;
        playCoins[3] = Letter.N;
        playCoins[4] = Letter.S;
        Bound[] memory coinsBounds = new Bound[](5);
        coinsBounds[4] = Bound({ positive: 0, negative: 4, proof: m.getProof(words, 6) });
        world.play({
            word: playCoins,
            proof: m.getProof(words, 5),
            coord: Coord({ x: 2, y: -6 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: coinsBounds
        });
        vm.stopPrank();
        assertEq(Points.get({ player: player1 }), 49);
        assertEq(Points.get({ player: player2 }), 43);
        assertEq(Points.get({ player: address(0) }), 92);
    }

    function testFuzz_RevertsWhen_CrossWordNoEmptyIncorrectBounds(
        uint16 boundsPositive,
        uint16 boundsNegative
    )
        public
    {
        vm.assume(boundsPositive != 0 || boundsNegative != 4);
        vm.startPrank(player2);
        Letter[] memory playCoins = new Letter[](5);
        playCoins[0] = Letter.C;
        playCoins[1] = Letter.O;
        playCoins[2] = Letter.I;
        playCoins[3] = Letter.N;
        playCoins[4] = Letter.S;
        Bound[] memory coinsBounds = new Bound[](5);
        coinsBounds[4] = Bound({ positive: boundsPositive, negative: boundsNegative, proof: m.getProof(words, 6) });
        bytes32[] memory coinsProof = m.getProof(words, 5);
        vm.expectRevert();
        world.play({
            word: playCoins,
            proof: coinsProof,
            coord: Coord({ x: 2, y: -6 }),
            direction: Direction.TOP_TO_BOTTOM,
            bounds: coinsBounds
        });
        vm.stopPrank();
    }
}
