from game import config

config = config.GameConfig()
print(config)

board = config.new_board()
board.draw()
