from game import Color
from game import Position


class Policy(object):
    pass


class HumanPolicy(Policy):

    def __init__(self, board, color):
        self._board = board
        self._color = Color.of(color)

    def next_position(self):
        b = self._board

        print("Column : ", end="")
        column = int(input())
        row = b.next_available_row(column)

        return Position(row, column)

