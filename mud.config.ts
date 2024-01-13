import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    // Config
    GameConfig: {
      keySchema: {},
      valueSchema: {
        status: "Status",
        endTime: "uint256",
        crossWordRewardFraction: "uint32",
      },
    },
    MerkleRootConfig: {
      keySchema: {},
      valueSchema: {
        value: "bytes32",
      },
    },
    VRGDAConfig: {
      keySchema: {},
      valueSchema: {
        startTime: "uint256",
        targetPrice: "int256",
        priceDecay: "int256",
        perDayInitial: "int256",
        power: "int256",
      },
    },
    // Game
    TileLetter: {
      keySchema: { x: "int32", y: "int32" },
      valueSchema: {
        value: "Letter",
      },
    },
    TilePlayer: {
      keySchema: { x: "int32", y: "int32" },
      valueSchema: {
        value: "address",
      },
    },
    Treasury: {
      keySchema: {},
      valueSchema: {
        value: "uint256",
      },
    },
    Points: {
      keySchema: { player: "address" },
      valueSchema: {
        value: "uint32",
      },
    },
    Spent: {
      keySchema: { player: "address", id: "uint256" },
      valueSchema: {
        value: "uint256",
      },
      offchainOnly: true,
    },
    LetterCount: {
      keySchema: { letter: "Letter" },
      valueSchema: {
        value: "uint32",
      },
    },
    Claimed: {
      keySchema: { player: "address" },
      valueSchema: {
        value: "bool",
      },
    },
    // Activity
    PlayResult: {
      keySchema: {
        id: "uint256",
      },
      valueSchema: {
        player: "address",
        direction: "Direction",
        timestamp: "uint256",
        x: "int32",
        y: "int32",
        word: "uint8[]",
        filledWord: "uint8[]",
      },
      offchainOnly: true,
    },
    PointsResult: {
      keySchema: {
        id: "uint256",
        player: "address",
        pointsId: "int16",
      },
      valueSchema: {
        points: "uint32",
      },
      offchainOnly: true,
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
