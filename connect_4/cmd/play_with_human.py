import random

from game import GameConfig
from policy import HumanPolicy
from policy import RandomPolicy
from policy import ModelPolicy
from policy import MCTSPolicy
from play import play_games

###########################
### Configuration to change
###########################

SHUFFLE_PLAYERS = False

###########################
### Initialize the env
###########################

config = GameConfig()
print(config)

if SHUFFLE_PLAYERS:
    if random.random() < 0.5:
        players = lambda b: [ModelPolicy(b, 'b'), HumanPolicy(b, 'w')]
    else:
        players = lambda b: [HumanPolicy(b, 'b'), ModelPolicy(b, 'w')]
else:
    players = lambda b: [ModelPolicy(b, 'b'), HumanPolicy(b, 'w')]


play_games(config, players=players)



