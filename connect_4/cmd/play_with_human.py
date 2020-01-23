# Disable all warnings from TensorFlow (Python side).
#
# - The order to disable warnings matters.
# - For CPP side, set # TF_CPP_MIN_LOG_LEVEL=3.

import warnings
with warnings.catch_warnings():
    warnings.filterwarnings("ignore",category=FutureWarning)

    from tensorflow.python.util import deprecation
    deprecation._PRINT_DEPRECATION_WARNINGS = False

    import tensorflow as tf

    # In addition, disable warning logging.
    tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)

    from tensorflow import keras

##########################
# Real fun code starts.
##########################

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
    return MCTSPolicy(b, c, explore=False, debug=True)


if SHUFFLE_PLAYERS and random.random() < 0.5:
    players = lambda b: [HumanPolicy(b, 'b'), BestPolicy(b, 'w')]
else:
    players = lambda b: [BestPolicy(b, 'b'), HumanPolicy(b, 'w')]


play_games(config, players=players)

