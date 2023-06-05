import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    // Config
    GameConfig: {
      keySchema: {},
      schema: {
        status: "Status",
        maxWords: "uint16",
        wordsPlayed: "uint16",
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
      keySchema: { player: "address" },
      schema: {
        value: "uint256",
      },
      ephemeral: true,
    },
  },
  enums: {
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
