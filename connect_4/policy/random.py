import random

from game import Color
from game import Position

from .policy import Policy


# Randomly selects the position.
class RandomPolicy(Policy):

    def __init__(self, board, color, name=None):
        self._board = board
        self._color = Color.of(color)
        self.name = name if name else "random_" + color

    def next_position(self):
        b = self._board

        columns = list(range(b.config.columns))
        random.shuffle(columns)
        for c in columns:
            r = b.next_available_row(c)
            if r != -1 :
                return Position(r, c)

        raise RuntimeError("N/A")

