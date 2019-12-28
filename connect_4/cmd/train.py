import datetime
import random
import os
import time

from data.sql import read_records
from data.sql import close as sql_close
from data import TrainingState
from model import convert_states_to_model_features
from model import build_model
from game import GameConfig

###########################
### Configuration to change
###########################

# 70 processes, 35 records per epoch, 50 epochs for process.
NUM_SAMPLES = 70 * 35 * 50
# NUM_SAMPLES = 1
NUM_EPOCHS = 1
BATCH_SIZE = 128
WEIGHTS_FILE = '.build/weights.h5'

###########################
### Initialize the env
###########################

print("=================================")
print(datetime.datetime.now())
print("=================================")

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

print("Building the model.")
input_shape = (config.rows, config.columns, 3)
m = build_model(input_shape, num_classes)
m.summary()

if os.path.exists(WEIGHTS_FILE):
    print("!!! Loading weights for model.")
    m.load_weights(WEIGHTS_FILE)


print("Training the model.")
m.fit(
        boards_np,
        {
            'policy': positions_np,
            'value' :rewards_np,
        },
        batch_size=BATCH_SIZE,
        epochs=NUM_EPOCHS,
        verbose=1)

# Create new file name for ckpt.
epoch = int(time.time())
file_name = WEIGHTS_FILE + ("-%d" % epoch)

print("Saving the model:", file_name)
m.save_weights(file_name)
print("Saved.")

# Using symbolic to avoid race condition.
if os.path.exists(WEIGHTS_FILE):
  os.remove(WEIGHTS_FILE)
os.symlink(os.path.basename(file_name), WEIGHTS_FILE)

sql_close()
