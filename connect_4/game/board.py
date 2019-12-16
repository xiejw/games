from game.position import Move
from game.position import Position
from game.position import Color


# For one game use. Not thread safe. Not sharable.
class Board(object):

    # - config is GameConfig
    def __init__(self, config):
        self.config = config
        self.moves = []
        self.position_dict = {}

    # - position_pair is (x, y)
    # - color can be 'b' or 'w'
    def new_move(self, position_pair, color):
        x, y = position_pair
        if isinstance(color, str):
            color = Color(color)
        return self._new_move(Move(Position(x,y), color))

    def _new_move(self, move):
        assert _is_move_legal(self.config, self.position_dict, move), (
            'Not legal move')
        self.moves.append(move)
        self.position_dict[move.position] = move.color

    # returns -1 for infeasiable.
    def next_available_row(self, column):
        for i in reversed(range(self.config.rows)):
            if Position(i, column) not in self.position_dict:
                return i
        return -1


    # Plots the board.
    def draw(self):
        _plot_board(self.config, self.position_dict)


# Checks whether the `new_move` is legal.
def _is_move_legal(config, position_dict, new_move):
    rows = config.rows
    columns = config.columns
    new_position = new_move.position

    if new_position in position_dict:
        # Should not be occupied.
        return False

    if new_position.x == rows - 1:
        # For final row, this is always OK.
        return True

    position_beneath = Position(new_position.x + 1, new_position.y)
    if position_beneath not in position_dict:
        # Now allowed. It must stack on something.
        return False

    return True


# Plots the board.
#
# Uses a free function to improve readability and isolation.
def _plot_board(config, position_dict):
    print("    ", end = '')
    for j in range(config.columns):
        print("%d " % j , end='')
    print("")

    print("    ", end = '')
    for j in range(config.columns):
        print("_ ", end='')
    print("")

    for i in range(config.rows):
        print("%2d: " % i, end='')
        for j in range(config.columns):
            color = position_dict.get(Position(i, j))
            if color is None:
                print("  ", end='')
            elif color == Color.WHITE:
                print("o ", end='')
            else:
                assert color == Color.BLACK
                print("x ", end='')

        print("")

    print("    ", end = '')
    for j in range(config.columns):
        print("_ ", end='')
    print("")

