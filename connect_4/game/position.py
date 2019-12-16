import enum

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


