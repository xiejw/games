import enum

# For one game use. Not thread safe. Not sharable.
class Board(object):

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
        assert move.position not in self.position_dict
        self.moves.append(move)
        self.position_dict[move.position] = move.color

    def draw(self):
        print("    ", end = '')
        for j in range(self.config.rows):
            print("%d " % j , end='')
        print("")

        print("    ", end = '')
        for j in range(self.config.rows):
            print("_ ", end='')
        print("")

        for i in range(self.config.rows):
            print("%2d: " % i, end='')
            for j in range(self.config.rows):
                color = self.position_dict.get(Position(i, j))
                if color is None:
                    print("  ", end='')
                elif color == Color.WHITE:
                    print("o ", end='')
                else:
                    assert color == Color.BLACK
                    print("x ", end='')

            print("")

        print("    ", end = '')
        for j in range(self.config.rows):
            print("_ ", end='')
        print("")


# Represents a position in game. Hashable.
class Position(object):

    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __hash__(self):
        return hash((self.x, self.y))

    def __eq__(self, o):
        return self.x == o.x and self.y == o.y


class Color(enum.Enum):
    NA = ''
    BLACK = 'b'
    WHITE = 'w'

# Represents a move in game. Basically, a position, with color
class Move(object):

    def __init__(self, position, color):
        self.position = position
        self.color = color


