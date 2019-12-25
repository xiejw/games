import random

from game import GameConfig
from policy import HumanPolicy
from policy import MCTSPolicy
from play import play_games

###########################
### Configuration to change
###########################

SHUFFLE_PLAYERS = True

###########################
### Initialize the env
###########################

config = GameConfig()
print(config)

def BestPolicy(b, c):
    return MCTSPolicy(b, c, debug=True)


if SHUFFLE_PLAYERS and random.random() < 0.5:
    players = lambda b: [HumanPolicy(b, 'b'), BestPolicy(b, 'w')]
else:
    players = lambda b: [BestPolicy(b, 'b'), HumanPolicy(b, 'w')]


play_games(config, players=players)

