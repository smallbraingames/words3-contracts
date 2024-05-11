// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

// LibPoints
error NoPointsForEmptyLetter();

// LibBoard
error BoundTooLong();
error EmptyLetterInBounds();

// LibPlay
error WordTooLong();
error InvalidWordStart();
error InvalidWordEnd();
error EmptyLetterNotOnExistingLetter();
error LetterOnExistingLetter();
error LonelyWord();
error NoLettersPlayed();
error WordNotInDictionary();
error InvalidBoundLength();
error NonzeroEmptyLetterBound();
error NonemptyBoundEdges();

// LibTreasury
error NoPoints();

// LibPrice
error Overflow();
