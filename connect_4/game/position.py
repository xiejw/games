import enum

# Represents a position in game. Hashable.
class Position(object):

    def __init__(self, x, y):
        self.x = x
        self.y = y

    @staticmethod
    def of(p):
        if isinstance(p, tuple):
            x, y = p
            return Position(x,y)
        return p


    def __hash__(self):
        return hash((self.x, self.y))

    def __eq__(self, o):
        return self.x == o.x and self.y == o.y


class Color(enum.Enum):
    NA = ''
    BLACK = 'b'
    WHITE = 'w'

    @staticmethod
    def of(c):
        if isinstance(c, str):
            c = Color(c)
        return c


# Represents a move in game. Basically, a position, with color
class Move(object):

    # - position_pair is (x, y)
    # - color can be 'b', 'w', color.{BLACK, WHITE}
    def __init__(self, position, color):
        self.position = Position.of(position)
        self.color = Color.of(color)


