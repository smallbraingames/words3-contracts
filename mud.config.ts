import { mudConfig } from "@latticexyz/config";

export default mudConfig({
  overrideSystems: {},
  tables: {
    TileTable: {
      primaryKeys: { x: "int32", y: "int32" },
      schema: {
        player: "address",
        letter: "Letter",
      },
      storeArgument: true,
    },
    WeightTable: {
      primaryKeys: { letter: "Letter" },
      schema: {
        weight: "int256",
      },
    },
    RewardsTable: {
      primaryKeys: { player: "address" },
      schema: {
        rewards: "uint256",
      },
    },
    TreasuryTable: {
      schema: {
        value: "uint256",
      },
    },
    ScoreTable: {
      primaryKeys: { player: "address" },
      schema: {
        score: "uint256",
      },
    },
    SpentTable: {
      primaryKeys: { player: "address" },
      schema: {
        score: "uint256",
      },
    },
  },
  enums: {
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
