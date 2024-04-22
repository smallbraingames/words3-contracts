import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import minimist from "minimist";
import { readFile } from "fs/promises";
import { wordToCode } from "./encodeLetter";

const main = async () => {
  const { tree, word } = minimist(process.argv.slice(2));
  console.log("Reading tree...");
  const treeData = (await readFile(tree)).toString();
  console.log("Loading tree...");
  const t = StandardMerkleTree.load(JSON.parse(treeData).tree);
  console.log(`Tree loaded. Generating proof for ${word}`);
  console.log(`Proof: ${t.getProof([wordToCode(word)])}`);
};

main();
