import random

from data.sql import read_records
from game import GameConfig
from game import SnapshotView

###########################
### Configuration to change
###########################

NUM_SAMPLES = 20000

###########################
### Initialize the env
###########################

config = GameConfig()
print(config)

print("Load SQl")
records = read_records(NUM_SAMPLES)

print("Converting to Snapshots: ", len(records))
snapshots = [SnapshotView.parsing(config, x) for x in records]

print("Shuffling")
random.shuffle(snapshots)  # inplace




