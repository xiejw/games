import random

from data.sql import read_records
from data import TrainingState
from data import convert_states_to_model_features
from game import GameConfig

###########################
### Configuration to change
###########################

# NUM_SAMPLES = 20000
NUM_SAMPLES = 2

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

print("Converting to feature planes.")
features, labels = convert_states_to_model_features(config, states)
boards_np = features
rewards_np, positions_np = labels

print("Print samples.")
print("Original State:", states[0])
print("Board Numpy Array:", boards_np[0])
print("Reward Numpy:", rewards_np[0], "dtype", rewards_np.dtype)
print("Position Int:", positions_np[0], "dtype:", positions_np.dtype)
