from game import GameConfig
from policy import RandomPolicy
from data.sql import store_record as sql_store
from play import play_games

###########################
### Configuration to change
###########################

STORE_IN_SQL = True

###########################
### Initialize the env
###########################

config = GameConfig()
print(config)

writer = sql_store if STORE_IN_SQL else None

players = lambda b: [RandomPolicy(b, 'b'), RandomPolicy(b, 'w')]

play_games(config, players=players, writer=writer)
