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

WEIGHTS_FILE_1 = '.build/weights.h5-1579687310'
WEIGHTS_FILE_2 = '.build/weights.h5-1580236502'

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
                MCTSPolicy(board, 'b', model=model_1, iterations=1600, explore=True),
                MCTSPolicy(board, 'w', model=model_2, iterations=1600, explore=True)
        ]
    return players_fn

assert NUM_EPOCHS % 2 == 0

history_1 = play_games(
        config,
        players=get_players(weight_files=[
                WEIGHTS_FILE_1,
                WEIGHTS_FILE_2,
        ]),
        num_epochs=NUM_EPOCHS // 2)

m1_wins = history_1['num_black_wins']
m2_wins = history_1['num_white_wins']

history_2 = play_games(
        config,
        players=get_players(weight_files=[
                WEIGHTS_FILE_2,
                WEIGHTS_FILE_1,
        ]),
        num_epochs=NUM_EPOCHS // 2)

m1_wins += history_2['num_white_wins']
m2_wins += history_2['num_black_wins']

print("Results for round 1: {}".format(history_1))
print("Results for round 2: {}".format(history_2))
print("Model 1 {} wins: {}".format(WEIGHTS_FILE_1, m1_wins))
print("Model 2 {} wins: {}".format(WEIGHTS_FILE_2, m2_wins))
