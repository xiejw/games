from game import GameConfig
from data.sql import store_record as sql_store
from play import play_games

###########################
### Configuration to change
###########################

NUM_EPOCHS = 100
STORE_IN_SQL = True

###########################
### Initialize the env
###########################

config = GameConfig()
print(config)

writer = sql_store if STORE_IN_SQL else None

play_games(config, num_epochs=NUM_EPOCHS, write=writer)
