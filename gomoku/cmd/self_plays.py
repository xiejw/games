import util
util.suppress_tf_warning()

import datetime

from game import GameConfig
from data.sql import store_record as sql_store
from data.sql import close as sql_close
from play import play_games
from policy import MCTSPolicy

###########################
### Configuration to change
###########################

# We rely on the `cmd/launcn_self_plays` to launch lots of self plays in a
# fine-controlled manner.
NUM_EPOCHS = 1
STORE_IN_SQL = True

###########################
### Initialize the env
###########################

print("=================================")
print(datetime.datetime.now())
print("=================================")

config = GameConfig()
print(config)

writer = sql_store if STORE_IN_SQL else None

players = lambda b: [
        MCTSPolicy(b, 'b', iterations=1600, explore=True),
        MCTSPolicy(b, 'w', iterations=1600, explore=True)]

play_games(config, players=players, num_epochs=NUM_EPOCHS, writer=writer)

sql_close()
