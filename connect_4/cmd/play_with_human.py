from game import GameConfig
from policy import HumanPolicy

config = GameConfig()
print(config)

b = config.new_board()
b.draw()

black_policy = HumanPolicy(b, 'b')
white_policy = HumanPolicy(b, 'w')

color = 'b'
while True:

    policy = black_policy if color == 'b' else white_policy

    position = policy.next_position()
    row, column = position.x, position.y

    print("Placed at (%2d, %2d)" % (row, column))
    b.new_move((row, column), color)
    b.draw()
    winner = b.winner_after_last_move()
    if winner != None:
        print("Found winner: %s" % winner)
        break

    color = 'w' if color == 'b' else 'b'
