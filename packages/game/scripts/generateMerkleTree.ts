import { readFile, writeFile } from "fs/promises";

import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import minimist from "minimist";
import { wordToCode } from "./encodeLetter";

const getAllWords = async (dictionary: string): Promise<string[]> => {
  const words = (await readFile(dictionary)).toString().split("\r\n");
  return words;
};

const main = async () => {
  const { dictionary, output } = minimist(process.argv.slice(2));
  const words = await getAllWords(dictionary);
  const tree = StandardMerkleTree.of<number[][]>(
    words.map((word) => [wordToCode(word.toLowerCase())]),
    ["uint8[]"]
  );
  const outputFilename = `${output}.json`;
  await writeFile(
    outputFilename,
    JSON.stringify({
      root: tree.root,
      tree: tree.dump(),
    })
  );
  console.log(`Saved to ${outputFilename}`);
};

main();
