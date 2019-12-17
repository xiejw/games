import collections

from .position import Position
from .position import Color


class SnapshotView(object):

    # call site make deepcopy. So this is a view.
    def __init__(self, config, position_dict):
        self._config = config
        self._position_dict = position_dict
        assert isinstance(position_dict, collections.OrderedDict)

    # returns a compact version of snapshot.
    def __str__(self):
        moves = []
        for position, color in self._position_dict.items():
            moves.append("%s(%s,%s)" % (color, position.x, position.y))
        return '_'.join(moves)


    # returns a compact version of board drawing.
    def board_view(self):
        config = self._config

        s = ''

        for i in range(config.rows):
            s += ("%2d: " % i)
            for j in range(config.columns):
                color = self._position_dict.get(Position(i, j))
                if color is None:
                    s += "  "
                elif color == Color.WHITE:
                    s += "o "
                else:
                    assert color == Color.BLACK
                    s += "x "

            s += "\n"
        return s


