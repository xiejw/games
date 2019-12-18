import random
import numpy as np

from data.sql import read_records
from data import TrainingState
from game import GameConfig
from game import Color
from game import Position

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

# rewards_np = np.array([x.reward for x in states])
# position_np = np.array([config.convert_position_to_index(x.position) for x in
#         states])
#
# print([x.position.__str__() for x in states])
# print(position_np)
# print(rewards_np)

# 3 is the number of feature planes.
boards_np = np.zeros([len(states), 3, config.rows, config.columns])
for i, state in enumerate(states):
    print(state)
    if state.next_player_color == Color.BLACK:
        boards_np[i, 2, :, :] = 1.0

    snapshot = state.snapshot
    for x in range(config.rows):
        for y in range(config.columns):
            color = snapshot.get(Position(x, y))
            if color is None:
                continue

            if color == Color.BLACK:
                boards_np[i, 0, x, y] = 1.0
            else:
                assert color == Color.WHITE
                boards_np[i, 1, x, y] = 1.0

print(boards_np)
boards_np = np.transpose(boards_np, [0, 2, 3, 1])
print(boards_np)

