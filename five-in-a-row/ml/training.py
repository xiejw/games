import numpy as np

from dataset import Dataset

import coremltools
import keras
from keras.models import Model
from keras.layers import Dense, Dropout, Flatten, Input, Concatenate
from keras.layers import Conv2D, MaxPooling2D

from keras import backend as K
assert K.image_data_format() != 'channels_first'

# Global Configuration.
boardSize = 8
fname = "games.txt"

save_coreml = True
cont_training = True

# Get data
ds = Dataset(fname, boardSize, shuffle=True)
train_data, test_data = ds.get_data()

print("Training data: {}".format(len(train_data.get_reward())))
print("Test data: {}".format(len(test_data.get_reward())))

# Build model
input_shape = (boardSize, boardSize, 1)

input_layer = Input(shape=input_shape)
board_layer = Conv2D(32, kernel_size=(3, 3), activation='relu')(input_layer)
board_layer = Conv2D(64, (3, 3), activation='relu')(board_layer)
board_layer = MaxPooling2D(pool_size=(2, 2))(board_layer)

board_layer = Dropout(0.25)(board_layer)
board_layer = Flatten()(board_layer)

next_player_layer = Input(shape=(1,))

middel_layer = Concatenate()([board_layer, next_player_layer])

middel_layer = Dense(256, activation='relu')(middel_layer)
middel_layer = Dropout(0.2)(middel_layer)
middel_layer = Dense(256, activation='relu')(middel_layer)
final_layer = Dropout(0.2)(middel_layer)

probability_output_shape = boardSize * boardSize
probability_output = Dense(
        probability_output_shape, activation='softmax', name='prob')(
                final_layer)
reward_output_layer = Dense(128, activation='relu')(final_layer)
reward_output = Dense(1, name='reward')(reward_output_layer)

inputs = [input_layer, next_player_layer]
outputs = [probability_output, reward_output]

model = Model(inputs, outputs)

model.compile(loss=['categorical_crossentropy', 'mse'], optimizer='adam')
model.summary()

if cont_training:
  print("Loading weights.")
  model.load_weights("distribution.h5")

if save_coreml:
  print("Saving the old model as DistributionLastIteration.")
  coreml_model = coremltools.converters.keras.convert(
      model, input_names=["board", "next_player"],
      output_names=["distribution", "reward"])
  coreml_model.save("DistributionLastIteration.mlmodel")

model.fit(
        [train_data.get_board(), train_data.get_nplayer()],
        [train_data.get_dist(), train_data.get_reward()],
        batch_size=128, epochs=12,
        validation_data=(
            [test_data.get_board(), test_data.get_nplayer()],
            [test_data.get_dist(), test_data.get_reward()])
        )
print("Saving weights.")
model.save_weights("distribution.h5")

preds = model.predict([test_data.get_board()[:1], test_data.get_nplayer()[:1]])
print("Distribution {}".format(preds[0]))
print("Reward {}".format(preds[1]))
print("Actual Distribution {}".format(test_data.get_dist()[0]))
print("Actual Reward {}".format(test_data.get_reward()[1]))

if save_coreml:
  print("Saving the new model as Distribution.")
  coreml_model = coremltools.converters.keras.convert(
      model, input_names=["board", "next_player"],
      output_names=["distribution", "reward"])
  coreml_model.save("Distribution.mlmodel")
