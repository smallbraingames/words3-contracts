import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  tables: {
    // Config
    GameConfig: {
      key: [],
      schema: {
        status: "Status",
        endTime: "uint256",
        crossWordRewardFraction: "uint32",
        maxPlayerSpend: "uint256",
        bonusDistance: "uint16",
      },
    },
    MerkleRootConfig: {
      key: [],
     schema: {
        value: "bytes32",
      },
    },
    VRGDAConfig: {
      key: [],
      schema: {
        startTime: "uint256",
        targetPrice: "int256",
        priceDecay: "int256",
        perDayInitial: "int256",
        power: "int256",
      },
    },
    // Game
    TileLetter: {
      key: ["x", "y"],
      schema: { x: "int32", y: "int32", value: "Letter" },
    },
    TilePlayer: {
      key: ["x", "y"],
      schema: { x: "int32", y: "int32", value: "address" }
    },
    Treasury: {
      key: [],
      schema: {
        value: "uint256",
      },
    },
    Points: {
      key: ["player"],
     schema: {
      player: "address",
        value: "uint32",
      },
    },
    Spent: {
      key: ["player"],
      schema: {
        player: "address",
        value: "uint256",
      },
    },
    LetterCount: {
      key: ["letter"],
      schema: {
        letter: "Letter",
        value: "uint32",
      },
    },
    Claimed: {
      key: ["player"],
      schema: {
        player: "address",
        value: "bool",
      },
    },
    // Activity
    SpentMove: {
      key: ["player", "id"],
      schema: {
        player: "address",
        id: "uint256",
        value: "uint256",
      },
     type: "offchainTable",
    },
    PlayResult: {
      key: ["id"],
      schema: {
        id: "uint256",
        player: "address",
        direction: "Direction",
        timestamp: "uint256",
        x: "int32",
        y: "int32",
        word: "uint8[]",
        filledWord: "uint8[]",
      },
      type: "offchainTable",
    },
    PointsResult: {
      key: ["id"],
      schema: {
        id: "uint256",
        player: "address",
        pointsId: "int16",
        points: "uint32",
      },
      type: "offchainTable"
    },
  },
  enums: {
    BonusType: ["MULTIPLY_WORD", "MULTIPLY_LETTER"],
    Direction: ["LEFT_TO_RIGHT", "TOP_TO_BOTTOM"],
    Status: ["NOT_STARTED", "STARTED", "OVER"],
    Letter: [
      "EMPTY",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z",
    ],
  },
});
