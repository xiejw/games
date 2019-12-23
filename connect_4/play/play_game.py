from data import ExperienceBuffer
from game import Color
from game import Move
from policy import HumanPolicy
from policy import RandomPolicy
from policy import ModelPolicy
from data.sql import store_record as sql_store


def play_games(config, players=None, num_epochs=1, writer=None):
    ebuf = ExperienceBuffer(config, writer=writer)

    for i in range(num_epochs):
        if num_epochs != 1:
            print("========================")
            print("Epoch: %3d/%d", i+1, num_epochs)

        b = config.new_board()
        b.draw()

        if players:
            black_policy, white_policy = players(b)
        else:
            black_policy = ModelPolicy(b, 'b')
            white_policy = ModelPolicy(b, 'w')


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