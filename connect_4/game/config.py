class GameConfig(object):

    def __init__(self, columns=7, rows=6):
        self.columns = columns
        self.rows = rows


    def __str__(self):
        return "Connect 4 Game Config (%dx%d)" % (self.columns, self.rows)
