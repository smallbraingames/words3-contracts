import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  deploy: {
    upgradeableWorldImplementation: true,
  },
  tables: {
    // Config
    GameConfig: {
      key: [],
      schema: {
        status: "Status",
        crossWordRewardFraction: "uint32",
        bonusDistance: "uint16",
        numDrawLetters: "uint8",
      },
    },
    FeeConfig: {
      key: [],
      schema: {
        feeTaker: "address",
        feeBps: "uint16",
      },
    },
    ClaimRestrictionConfig: {
      key: [],
      schema: {
        claimRestrictionBlock: "uint256"
      }
    },
    MerkleRootConfig: {
      key: [],
      schema: {
        value: "bytes32",
      },
    },
    PriceConfig: {
      key: [],
      schema: {
        minPrice: "uint256",
        wadPriceIncreaseFactor: "int256",
        wadPower: "int256",
        wadScale: "int256",
      },
    },
    DrawLetterOdds: {
      key: [],
      schema: {
       value: "uint8[]" // Letters index the array (A is index 1, B is index 2, etc.)
      },
    },
    
    // Board
    TileLetter: {
      key: ["x", "y"],
      schema: { x: "int32", y: "int32", value: "Letter" },
    },
    TilePlayer: {
      key: ["x", "y"],
      schema: { x: "int32", y: "int32", value: "address" }
    },

    // Letters
    PlayerLetters: {
      key: ["player", "letter"],
      schema: {
        player: "address",
        letter: "Letter",
        value: "uint32",
      },
    },
    DrawLastSold: {
      key: [],
      schema: {
        price: "uint256",
        blockNumber: "uint256",
      }
    },
    DrawCount: {
      key: [],
      schema: {
        value: "uint32",
      },
    },

    // Points & Treasury
    Points: {
      key: ["player"],
      schema: {
        player: "address",
        value: "uint32",
      },
    },
    Treasury: {
      key: [],
      schema: {
        value: "uint256",
      },
    },
    Spent: {
      key: ["player"],
      schema: {
        player: "address",
        value: "uint256",
      },
    },
    
    // Activity (offchain tables used to emit events useful for indexing)
    UpdateId: {
      key: [],
      schema: {
        value: "uint256",
      },
    },
    PlayUpdate: {
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
      type: "offchainTable"
    },
    PointsUpdate: {
      key: ["id", "pointsId"],
      schema: {
        id: "uint256",
        player: "address",
        pointsId: "int16",
        points: "uint32",
      },
      type: "offchainTable"
    },
    PointsClaimedUpdate: {
      key: ["id"],
      schema: {
        id: "uint256",
        player: "address",
        points: "uint32",
        value: "uint256",
        timestamp: "uint256",
      },
      type: "offchainTable",
    },
    DrawUpdate: {
      key: ["id"],
      schema: {
        id: "uint256",
        player: "address",
        value: "uint256",
        timestamp: "uint256",
      },
      type: "offchainTable",
    }
  },
  enums: {
    BonusType: ["MULTIPLY_WORD", "MULTIPLY_LETTER"],
    Direction: ["LEFT_TO_RIGHT", "TOP_TO_BOTTOM"],
    Status: ["NOT_STARTED", "STARTED"],
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
