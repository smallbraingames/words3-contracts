// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

error BoundsDoNotMatch();
error InvalidBoundLength();
error InvalidBoundEdges();
error BoundTooLong();
error EmptyLetterInBounds();
error InvalidEmptyLetterBound();

error EmptyLetterNotOnExisting();
error LetterOnExistingTile();

error NoLettersPlayed();
error InvalidWord();
error InvalidWordStart();
error InvalidWordEnd();
error LonelyWord();
error WordTooLong();
error InvalidCrossProofs();

error PaymentTooLow();

error AlreadySetupGrid();
error AlreadyClaimedPayout();
error GameOver();
error GameNotOver();
