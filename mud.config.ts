import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  worldContractName: "GatedWorld",
  tables: {
    // Config
    GameConfig: {
      keySchema: {},
      schema: {
        status: "Status",
        endTime: "uint256",
        crossWordRewardFraction: "uint32",
      },
    },
    MerkleRootConfig: {
      keySchema: {},
      schema: {
        value: "bytes32",
      },
    },
    VRGDAConfig: {
      keySchema: {},
      schema: {
        startTime: "uint256",
        targetPrice: "int256",
        priceDecay: "int256",
        perDay: "int256",
      },
    },
    // Game
    TileLetter: {
      keySchema: { x: "int32", y: "int32" },
      schema: {
        value: "Letter",
      },
    },
    TilePlayer: {
      keySchema: { x: "int32", y: "int32" },
      schema: {
        value: "address",
      },
    },
    Treasury: {
      keySchema: {},
      schema: {
        value: "uint256",
      },
    },
    Points: {
      keySchema: { player: "address" },
      schema: {
        value: "uint32",
      },
    },
    Spent: {
      keySchema: { player: "address", id: "uint256" },
      schema: {
        value: "uint256",
      },
      ephemeral: true,
    },
    LetterCount: {
      keySchema: { letter: "Letter" },
      schema: {
        value: "uint32",
      },
    },
    Claimed: {
      keySchema: { player: "address" },
      schema: {
        value: "bool",
      },
    },
    // Activity
    PlayResult: {
      keySchema: {
        id: "uint256",
      },
      schema: {
        player: "address",
        direction: "Direction",
        timestamp: "uint256",
        x: "int32",
        y: "int32",
        word: "uint8[]",
        filledWord: "uint8[]",
      },
      ephemeral: true,
    },
    PointsResult: {
      keySchema: {
        id: "uint256",
        player: "address",
      },
      schema: {
        points: "uint32",
      },
      ephemeral: true,
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
