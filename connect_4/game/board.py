class Board(object):

    def __init__(self, config):
        self.config = config

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
                print("* ", end='')
            print("")

        print("    ", end = '')
        for j in range(self.config.rows):
            print("_ ", end='')
        print("")

