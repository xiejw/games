from data import ExperienceBuffer
from game import GameConfig
from game import Color
from game import Move
from policy import HumanPolicy
from policy import RandomPolicy
from data.sql import store_record as sql_store

###########################
### Configuration to change
###########################

# NUM_EPOCHS = 1
NUM_EPOCHS = 2000
STORE_IN_SQL = True

###########################
### Initialize the env
###########################

config = GameConfig()
print(config)

writer = sql_store if STORE_IN_SQL else None
ebuf = ExperienceBuffer(config, writer=writer)

for i in range(NUM_EPOCHS):
    if NUM_EPOCHS != 1:
        print("========================")
        print("Epoch: ", i)

    b = config.new_board()
    b.draw()

    black_policy = RandomPolicy(b, 'b')
    white_policy = RandomPolicy(b, 'w')
    # white_policy = HumanPolicy(b, 'w')

    ebuf.start_epoch()

    color = 'b'
    winner = None
    while True:

        policy = black_policy if color == 'b' else white_policy
        print("\n==> Inquiry", policy.name)

        position = policy.next_position()
        row, column = position.x, position.y

        print("Placed at (%2d, %2d)" % (row, column))
        move = Move((row, column), color)
        ebuf.add_move(move)
        b.new_move(move)
        b.draw()

        winner = b.winner_after_last_move()
        if winner == None:
            pass
        elif winner == Color.NA:
            print("Tie")
            break
        else:
            print("Found winner: %s" % winner)
            break

        color = 'w' if color == 'b' else 'b'

    ebuf.end_epoch(winner)
    ebuf.report()

ebuf.summary()
