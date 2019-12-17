import random
import numpy as np

from data.sql import read_records
from data import TrainingState
from game import GameConfig

###########################
### Configuration to change
###########################

# NUM_SAMPLES = 20000
NUM_SAMPLES = 20

###########################
### Initialize the env
###########################

config = GameConfig()
print(config)

print("Load SQl")
records = read_records(NUM_SAMPLES)

print("Converting to states: ", len(records))
states = [TrainingState.parsing(config, x) for x in records]

print("Shuffling")
random.shuffle(states)  # inplace

# rewards_np = np.array([x.reward for x in states])
# position_np = np.array([config.convert_position_to_index(x.position) for x in
#         states])
#
# print([x.position.__str__() for x in states])
# print(position_np)
# print(rewards_np)





