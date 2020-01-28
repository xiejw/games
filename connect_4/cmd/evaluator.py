import util
util.suppress_tf_warning()

import datetime

from game import GameConfig
from play import play_games
from policy import MCTSPolicy

###########################
### Configuration to change
###########################

NUM_EPOCHS = 20

###########################
### Initialize the env
###########################

print("=================================")
print(datetime.datetime.now())
print("=================================")

config = GameConfig()
print(config)

# To avoid deterministic results, we also enable exploration
players = lambda b: [
        MCTSPolicy(b, 'b', iterations=1600, explore=True),
        MCTSPolicy(b, 'w', iterations=1600, explore=True)]

play_games(config, players=players, num_epochs=NUM_EPOCHS)

