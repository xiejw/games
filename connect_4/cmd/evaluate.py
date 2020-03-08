import util
util.suppress_tf_warning()

import datetime

from game import GameConfig
from play import play_games
from policy import MCTSPolicy
from model import build_model

###########################
### Configuration to change
###########################

NUM_EPOCHS = 20 * 2

###########################
### Initialize the env
###########################

print("=================================")
print(datetime.datetime.now())
print("=================================")

config = GameConfig()
print(config)

WEIGHTS = [
        '.build/weights.h5-1583173597',  # Mar  2 (10:28), 2020. Iter  0 random
        '.build/weights.h5-1583244370',  # Mar  3 (06:06), 2020. Iter  1
        '.build/weights.h5-1583331870',  # Mar  4 (06:24), 2020. Iter  2
        '.build/weights.h5-1583437368',  # Mar  5 (11:42), 2020. Iter  3
        '.build/weights.h5-1583536363',  # Mar  6 (15:12), 2020. Iter  4
        '.build/weights.h5-1583640072',  # Mar  7 (20:01), 2020. Iter  5
]

WEIGHTS_FILE_1 = WEIGHTS[-2]
WEIGHTS_FILE_2 = WEIGHTS[-1]

# Final in previous test.
# WEIGHTS_FILE_2 = '.build/weights.h5-1580236502' # Jan 28

# Builds a model and loads weights from specific weight file.
def _build_model(config, weight_file):
    num_classes = config.rows * config.columns
    input_shape = (config.rows, config.columns, 3)
    m = build_model(input_shape, num_classes)
    print("Loading model from:", weight_file)
    m.load_weights(weight_file)
    return m

# To avoid deterministic results, we also enable exploration
def get_players(weight_files):
    def players_fn(board):
        model_1 = _build_model(config, weight_files[0])
        model_2 = _build_model(config, weight_files[1])

        return [
                MCTSPolicy(board, 'b', model=model_1, iterations=1600, explore=True, debug=True),
                MCTSPolicy(board, 'w', model=model_2, iterations=1600, explore=True, debug=True)
        ]
    return players_fn

assert NUM_EPOCHS % 2 == 0

history_1 = play_games(
        config,
        players=get_players(weight_files=[
                WEIGHTS_FILE_1,
                WEIGHTS_FILE_2,
        ]),
        num_epochs=NUM_EPOCHS // 2,
        avoid_dup=True)

m1_wins = history_1['num_black_wins']
m2_wins = history_1['num_white_wins']

history_2 = play_games(
        config,
        players=get_players(weight_files=[
                WEIGHTS_FILE_2,
                WEIGHTS_FILE_1,
        ]),
        num_epochs=NUM_EPOCHS // 2,
        avoid_dup=True)

m1_wins += history_2['num_white_wins']
m2_wins += history_2['num_black_wins']

print("Results for round 1: {}".format(history_1))
print("Results for round 2: {}".format(history_2))
print("Model 1 {} wins: {}".format(WEIGHTS_FILE_1, m1_wins))
print("Model 2 {} wins: {}".format(WEIGHTS_FILE_2, m2_wins))
