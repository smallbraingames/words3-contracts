/* Autogenerated file. Do not edit manually. */

import {
  defineComponent,
  Type as RecsType,
  type World,
} from "@latticexyz/recs";

export function defineContractComponents(world: World) {
  return {
    GameConfig: (() => {
      return defineComponent(
        world,
        {
          status: RecsType.Number,
          endTime: RecsType.BigInt,
          crossWordRewardFraction: RecsType.Number,
        },
        {
          id: "0x0000000000000000000000000000000047616d65436f6e666967000000000000",
          metadata: {
            componentName: "GameConfig",
            tableName: ":GameConfig",
            keySchema: {},
            valueSchema: {
              status: "uint8",
              endTime: "uint256",
              crossWordRewardFraction: "uint32",
            },
          },
        } as const
      );
    })(),
    MerkleRootConfig: (() => {
      return defineComponent(
        world,
        {
          value: RecsType.String,
        },
        {
          id: "0x000000000000000000000000000000004d65726b6c65526f6f74436f6e666967",
          metadata: {
            componentName: "MerkleRootConfig",
            tableName: ":MerkleRootConfig",
            keySchema: {},
            valueSchema: { value: "bytes32" },
          },
        } as const
      );
    })(),
    VRGDAConfig: (() => {
      return defineComponent(
        world,
        {
          startTime: RecsType.BigInt,
          targetPrice: RecsType.BigInt,
          priceDecay: RecsType.BigInt,
          perDay: RecsType.BigInt,
        },
        {
          id: "0x000000000000000000000000000000005652474441436f6e6669670000000000",
          metadata: {
            componentName: "VRGDAConfig",
            tableName: ":VRGDAConfig",
            keySchema: {},
            valueSchema: {
              startTime: "uint256",
              targetPrice: "int256",
              priceDecay: "int256",
              perDay: "int256",
            },
          },
        } as const
      );
    })(),
    TileLetter: (() => {
      return defineComponent(
        world,
        {
          value: RecsType.Number,
        },
        {
          id: "0x0000000000000000000000000000000054696c654c6574746572000000000000",
          metadata: {
            componentName: "TileLetter",
            tableName: ":TileLetter",
            keySchema: { x: "int32", y: "int32" },
            valueSchema: { value: "uint8" },
          },
        } as const
      );
    })(),
    TilePlayer: (() => {
      return defineComponent(
        world,
        {
          value: RecsType.String,
        },
        {
          id: "0x0000000000000000000000000000000054696c65506c61796572000000000000",
          metadata: {
            componentName: "TilePlayer",
            tableName: ":TilePlayer",
            keySchema: { x: "int32", y: "int32" },
            valueSchema: { value: "address" },
          },
        } as const
      );
    })(),
    Treasury: (() => {
      return defineComponent(
        world,
        {
          value: RecsType.BigInt,
        },
        {
          id: "0x0000000000000000000000000000000054726561737572790000000000000000",
          metadata: {
            componentName: "Treasury",
            tableName: ":Treasury",
            keySchema: {},
            valueSchema: { value: "uint256" },
          },
        } as const
      );
    })(),
    Points: (() => {
      return defineComponent(
        world,
        {
          value: RecsType.Number,
        },
        {
          id: "0x00000000000000000000000000000000506f696e747300000000000000000000",
          metadata: {
            componentName: "Points",
            tableName: ":Points",
            keySchema: { player: "address" },
            valueSchema: { value: "uint32" },
          },
        } as const
      );
    })(),
    Spent: (() => {
      return defineComponent(
        world,
        {
          value: RecsType.BigInt,
        },
        {
          id: "0x000000000000000000000000000000005370656e740000000000000000000000",
          metadata: {
            componentName: "Spent",
            tableName: ":Spent",
            keySchema: { player: "address", id: "uint256" },
            valueSchema: { value: "uint256" },
          },
        } as const
      );
    })(),
    LetterCount: (() => {
      return defineComponent(
        world,
        {
          value: RecsType.Number,
        },
        {
          id: "0x000000000000000000000000000000004c6574746572436f756e740000000000",
          metadata: {
            componentName: "LetterCount",
            tableName: ":LetterCount",
            keySchema: { letter: "uint8" },
            valueSchema: { value: "uint32" },
          },
        } as const
      );
    })(),
    Claimed: (() => {
      return defineComponent(
        world,
        {
          value: RecsType.Boolean,
        },
        {
          id: "0x00000000000000000000000000000000436c61696d6564000000000000000000",
          metadata: {
            componentName: "Claimed",
            tableName: ":Claimed",
            keySchema: { player: "address" },
            valueSchema: { value: "bool" },
          },
        } as const
      );
    })(),
    PlayResult: (() => {
      return defineComponent(
        world,
        {
          player: RecsType.String,
          direction: RecsType.Number,
          timestamp: RecsType.BigInt,
          x: RecsType.Number,
          y: RecsType.Number,
          word: RecsType.NumberArray,
          filledWord: RecsType.NumberArray,
        },
        {
          id: "0x00000000000000000000000000000000506c6179526573756c74000000000000",
          metadata: {
            componentName: "PlayResult",
            tableName: ":PlayResult",
            keySchema: { id: "uint256" },
            valueSchema: {
              player: "address",
              direction: "uint8",
              timestamp: "uint256",
              x: "int32",
              y: "int32",
              word: "uint8[]",
              filledWord: "uint8[]",
            },
          },
        } as const
      );
    })(),
    PointsResult: (() => {
      return defineComponent(
        world,
        {
          points: RecsType.Number,
        },
        {
          id: "0x00000000000000000000000000000000506f696e7473526573756c7400000000",
          metadata: {
            componentName: "PointsResult",
            tableName: ":PointsResult",
            keySchema: { id: "uint256", player: "address" },
            valueSchema: { points: "uint32" },
          },
        } as const
      );
    })(),
  };
}
