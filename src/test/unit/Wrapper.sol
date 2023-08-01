import {Letter, Direction} from "codegen/Types.sol";

import {Bound} from "common/Bound.sol";
import {Coord} from "common/Coord.sol";
import {Bonus} from "common/Bonus.sol";

import {LibPlay} from "libraries/LibPlay.sol";
import {LibPoints} from "libraries/LibPoints.sol";
import {LibBoard} from "libraries/LibBoard.sol";

contract Wrapper {
    function playCheckCrossWords(Letter[] memory word, Coord memory coord, Direction direction, Bound[] memory bounds)
        public
        view
        returns (address[] memory)
    {
        return LibPlay.checkCrossWords(word, coord, direction, bounds);
    }

    function boardGetCoordsOutsideBound(Coord memory coord, Direction direction, Bound memory bound)
        public
        pure
        returns (Coord memory, Coord memory)
    {
        return LibBoard.getCoordsOutsideBound(coord, direction, bound);
    }

    function pointsGetBonusLetterPoints(Letter letter, Bonus memory bonus) public pure returns (uint32) {
        return LibPoints.getBonusLetterPoints(letter, bonus);
    }
}
