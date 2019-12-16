from game import board

class GameConfig(object):

    def __init__(self, columns=7, rows=6):
        self.columns = columns
        self.rows = rows
        assert columns < 10, 'columns should be less than 10'
        assert rows < 10, 'rows should be less than 10'


    def __str__(self):
        return "Connect 4 Game Config (%dx%d)" % (self.columns, self.rows)

    def new_board(self):
        return board.Board(self)
