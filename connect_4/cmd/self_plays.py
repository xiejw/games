import datetime

from game import GameConfig
from data.sql import store_record as sql_store
from play import play_games
from policy import MCTSPolicy

###########################
### Configuration to change
###########################

NUM_EPOCHS = 50
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
        MCTSPolicy(b, 'b', iterations=600, explore=True),
        MCTSPolicy(b, 'w', iterations=600, explore=True)]

play_games(config, players=players, num_epochs=NUM_EPOCHS, writer=writer)
