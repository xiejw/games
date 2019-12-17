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
        legal_moves = b.legal_moves()

        if not legal_moves:
            raise RuntimeError("N/A")

        return random.choice(legal_moves)

