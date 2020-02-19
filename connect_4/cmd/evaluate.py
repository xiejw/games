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
        '.build/weights.h5-1580693471',  # Feb  2 (17:31), 2020. Iter  0 random
        '.build/weights.h5-1580745471',  # Feb  3 (07:57), 2020. Iter  1
        '.build/weights.h5-1580810590',  # Feb  4 (02:23), 2020. Iter  2
        '.build/weights.h5-1580887732',  # FEb  4 (23:28), 2020, Iter  3
        '.build/weights.h5-1580963956',  # Feb  5 (20:39), 2020. Iter  4
        '.build/weights.h5-1581041476',  # Feb  6 (18:11), 2020. Iter  5
        '.build/weights.h5-1581125796',  # Feb  7 (17:36), 2020. Iter  6
        '.build/weights.h5-1581215559',  # Feb  8 (18:32), 2020. Iter  7
        '.build/weights.h5-1581307364',  # Feb  9 (20:02), 2020. Iter  8
        '.build/weights.h5-1581623488',  # Feb 13 (11:51), 2020. Iter  9
        '.build/weights.h5-1581722260',  # Feb 14 (15:17), 2020. Iter 10
        '.build/weights.h5-1581815977',  # Feb 15 (17:19), 2020. Iter 11
        '.build/weights.h5-1581908262',  # Feb 16 (18:57), 2020. Iter 12
        '.build/weights.h5-1582007688',  # Feb 17 (22:34), 2020. Iter 13
        '.build/weights.h5-1582100291',  # Feb 19 (00:18), 2020. Iter 14
]

# Results
#
# Iter 0 vs 1
# Results for round 1: {'num_black_wins': 3, 'num_white_wins': 15, 'num_ties': 2}
# Results for round 2: {'num_black_wins': 14, 'num_white_wins': 5, 'num_ties': 1}
# Model 1 .build/weights.h5-1580693471 wins: 8
# Model 2 .build/weights.h5-1580745471 wins: 29

# Iter 1 vs 2
# Results for round 1: {'num_black_wins': 3, 'num_white_wins': 16, 'num_ties': 1}
# Results for round 2: {'num_black_wins': 15, 'num_white_wins': 3, 'num_ties': 2}
# Model 1 .build/weights.h5-1580745471 wins: 6
# Model 2 .build/weights.h5-1580810590 wins: 31

# Iter 2 vs 3
# Results for round 1: {'num_black_wins': 2, 'num_white_wins': 13, 'num_ties': 5}
# Results for round 2: {'num_black_wins': 10, 'num_white_wins': 3, 'num_ties': 7}
# Model 1 .build/weights.h5-1580810590 wins: 5
# Model 2 .build/weights.h5-1580887732 wins: 23

# Iter 3 vs 4
# Results for round 1: {'num_black_wins': 9, 'num_white_wins': 9, 'num_ties': 2}
# Results for round 2: {'num_black_wins': 10, 'num_white_wins': 7, 'num_ties': 3}
# Model 1 .build/weights.h5-1580887732 wins: 16
# Model 2 .build/weights.h5-1580963956 wins: 19

# Iter 4 vs 5
# Results for round 1: {'num_black_wins': 3, 'num_white_wins': 14, 'num_ties': 3}
# Results for round 2: {'num_black_wins': 14, 'num_white_wins': 3, 'num_ties': 3}
# Model 1 .build/weights.h5-1580963956 wins: 6
# Model 2 .build/weights.h5-1581041476 wins: 28

# Iter 5 vs 6
# Results for round 1: {'num_black_wins': 6, 'num_white_wins': 7, 'num_ties': 7}
# Results for round 2: {'num_black_wins': 9, 'num_white_wins': 5, 'num_ties': 6}
# Model 1 .build/weights.h5-1581041476 wins: 11
# Model 2 .build/weights.h5-1581125796 wins: 16

# Iter 6 vs 7
# Results for round 1: {'num_black_wins': 3, 'num_white_wins': 8, 'num_ties': 9}
# Results for round 2: {'num_black_wins': 12, 'num_white_wins': 4, 'num_ties': 4}
# Model 1 .build/weights.h5-1581125796 wins: 7
# Model 2 .build/weights.h5-1581215559 wins: 20

# Iter 7 vs 8
# Results for round 1: {'num_black_wins': 3, 'num_white_wins': 9, 'num_ties': 8}
# Results for round 2: {'num_black_wins': 7, 'num_white_wins': 1, 'num_ties': 12}
# Model 1 .build/weights.h5-1581215559 wins: 4
# Model 2 .build/weights.h5-1581307364 wins: 16

# Iter 8 vs 9
# Results for round 1: {'num_black_wins': 3, 'num_white_wins': 7, 'num_ties': 10}
# Results for round 2: {'num_black_wins': 7, 'num_white_wins': 2, 'num_ties': 11}
# Model 1 .build/weights.h5-1581307364 wins: 5
# Model 2 .build/weights.h5-1581623488 wins: 14

# Iter 9 vs 10
# Results for round 1: {'num_black_wins': 1, 'num_white_wins': 5, 'num_ties': 14}
# Results for round 2: {'num_black_wins': 8, 'num_white_wins': 1, 'num_ties': 11}
# Model 1 .build/weights.h5-1581623488 wins: 2
# Model 2 .build/weights.h5-1581722260 wins: 13

# Iter 10 vs 11
# Results for round 1: {'num_black_wins': 1, 'num_white_wins': 9, 'num_ties': 10}
# Results for round 2: {'num_black_wins': 1, 'num_white_wins': 3, 'num_ties': 16}
# Model 1 .build/weights.h5-1581722260 wins: 4
# Model 2 .build/weights.h5-1581815977 wins: 10

# Iter 11 vs 12
# Results for round 1: {'num_black_wins': 4, 'num_white_wins': 2, 'num_ties': 14}
# Results for round 2: {'num_black_wins': 10, 'num_white_wins': 2, 'num_ties': 8}
# Model 1 .build/weights.h5-1581815977 wins: 6
# Model 2 .build/weights.h5-1581908262 wins: 12

# Iter 12 vs 13
# Results for round 1: {'num_black_wins': 5, 'num_white_wins': 4, 'num_ties': 11}
# Results for round 2: {'num_black_wins': 5, 'num_white_wins': 4, 'num_ties': 11}
# Model 1 .build/weights.h5-1581908262 wins: 9
# Model 2 .build/weights.h5-1582007688 wins: 9

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
