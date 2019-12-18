import random

from data.sql import read_records
from data import TrainingState
from model import convert_states_to_model_features
from model import build_model
from game import GameConfig

###########################
### Configuration to change
###########################

NUM_SAMPLES = 20000
NUM_EPOCHS = 12

###########################
### Initialize the env
###########################

config = GameConfig()
print(config)

num_classes = config.rows * config.columns

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

print("Board Numpy Array:",
        boards_np[0],
        "dtype:", boards_np.dtype,
        "shape:", boards_np.shape)

print("Reward Numpy:",
        rewards_np[0],
        "dtype:", rewards_np.dtype,
        "shape:", rewards_np.shape)

print("Position:",
        positions_np[0],
        "dtype:", positions_np.dtype,
        "shape:", positions_np.shape)

input_shape = (config.rows, config.columns, 3)
m = build_model(input_shape, num_classes)
m.summary()

m.fit(
        boards_np,
        positions_np,
        batch_size=32,
        epochs=NUM_EPOCHS,
        verbose=1)

m.save_weights('.build/weights.h5')


