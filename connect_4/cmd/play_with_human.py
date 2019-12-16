from game import config
from game import board

config = config.GameConfig()
print(config)

b = config.new_board()
b.draw()

b.new_move((1,1), 'b')
b.draw()
