from game import config
from game import board as board_lib

config = config.GameConfig()
print(config)

b = config.new_board()
b.draw()

color = 'b'
while True:

    print("Column : ", end="")
    column = int(input())
    row = b.next_available_row(column)
    print("Placed at (%2d, %2d)" % (row, column))
    b.new_move((row, column), color)
    b.draw()
    winner = b.winner_after_last_move()
    if winner != None:
        print("Found winner: %s" % winner)
        break

    color = 'w' if color == 'b' else 'b'
