from game import Color
from game import Position
from .policy import Policy


class HumanPolicy(Policy):

    def __init__(self, board, color, name=None):
        self._board = board
        self._color = Color.of(color)
        self.name = name if name else "human_" + color

    def next_position(self):
        b = self._board

        print("Column : ", end="")
        column = int(input())
        row = b.next_available_row(column)

        return Position(row, column)

