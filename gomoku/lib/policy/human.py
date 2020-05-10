from game import Color
from game import Position

from .policy import Policy

_column_key_map = {
        'a': 10,
        'b': 11,
        'c': 12,
        'd': 13,
        'e': 14,
}

def _parse_input_num(x):
    if x in _column_key_map:
        return _column_key_map[x]
    return int(x)


# Ask for next position from human input.
class HumanPolicy(Policy):

    def __init__(self, board, color, name=None):
        self._board = board
        self._color = Color.of(color)
        self.name = name if name else "human_" + color

    def next_position(self):
        b = self._board
        legal_positions = b.legal_positions()

        # Loop forever until valid input.
        while True:
            try:
                print("Row    : ", end="")
                row = _parse_input_num(input())
                print("Column : ", end="")
                column = _parse_input_num(input())

                pos = Position(row, column)

                for legal_pos in legal_positions:
                    if pos == legal_pos:
                        return pos

                print("This pos is occupied. Try again.")
                continue

            except KeyboardInterrupt:
                print("Aborted due to Ctrl-C.")
                import sys
                sys.exit()
            except:
                print("Unexpected error due to invalid input. Try again.")

