from .board import Board

# Should be treated as immutable
class GameConfig(object):

    def __init__(self, columns=15, rows=15):
        self.columns = columns
        self.rows = rows
        assert columns > 0, 'columns should be non-zero'
        assert rows > 10, 'rows should be non-zero'

    def __str__(self):
        return "Gomoku Game Config (%dx%d)" % (self.rows, self.columns)

    def new_board(self):
        return Board(self)

    def convert_position_to_index(self, position):
        return position.x * self.columns + position.y
