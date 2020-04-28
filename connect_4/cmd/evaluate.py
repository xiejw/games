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
    '.build/weights.h5-1584988775',  # Mar 23 (11:39), 2020. Iter  0 random
    '.build/weights.h5-1585049323',  # Mar 24 (04:28), 2020. Iter  1
    '.build/weights.h5-1585124939',  # Mar 25 (01:29), 2020. Iter  2
    '.build/weights.h5-1585209034',  # Mar 26 (00:50), 2020. Iter  3
    '.build/weights.h5-1585300158',  # Mar 27 (02:09), 2020. Iter  4
    '.build/weights.h5-1585392989',  # Mar 28 (03:56), 2020. Iter  5
    '.build/weights.h5-1585489222',  # Mar 29 (06:40), 2020. Iter  6
    '.build/weights.h5-1585596836',  # Mar 30 (12:33), 2020. Iter  7
    '.build/weights.h5-1585710855',  # Mar 31 (20:14), 2020. Iter  8
    '.build/weights.h5-1585834790',  # Apr  2 (06:39), 2020. Iter  9
    '.build/weights.h5-1585955191',  # Apr  3 (16:06), 2020. Iter 10
    '.build/weights.h5-1586078996',  # Apr  5 (02:29), 2020. Iter 11
    '.build/weights.h5-1586204163',  # Apr  6 (13:16), 2020. Iter 12
    '.build/weights.h5-1586328941',  # Apr  7 (23:55), 2020. Iter 13
    '.build/weights.h5-1586450253',  # Apr  9 (09:37), 2020. Iter 14
    '.build/weights.h5-1586565805',  # Apr 10 (17:43), 2020. Iter 15
    '.build/weights.h5-1586675162',  # Apr 12 (00:06), 2020. Iter 16
    '.build/weights.h5-1586786580',  # Apr 13 (07:03), 2020. Iter 17
    '.build/weights.h5-1586902225',  # Apr 14 (15:10), 2020. Iter 18
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
