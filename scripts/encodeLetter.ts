export const codeToLetter = (code: number): string => {
  if (code === 0) return "";
  if (code < 1 || code > 26) {
    throw new Error("Code must be between 1 and 26");
  }
  return String.fromCharCode(code + 64);
};

export const letterToCode = (letter: string): number => {
  const code = letter.toUpperCase().charCodeAt(0) - 64;
  if (code < 1 || code > 26) {
    throw new Error("Letter must be between A and Z");
  }
  return code;
};

export const wordToCode = (word: string): number[] => {
  return word.split("").map((letter) => letterToCode(letter));
};
