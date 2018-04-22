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
fname = "/Users/xiejw/Desktop/games.txt"
shortMode = False

save_coreml = True
cont_training = True

# Get data
ds = Dataset(fname, boardSize, shortMode)
board_l, next_player_l, reward_l = ds.get_data()

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

# if cont_training:
#   print("Loading weights.")
#   model.load_weights("distribution.h5")

# print "=======", ds.content[0]
# preds = model.predict([board_l[:1], next_player_l[:1]])
# pred = preds[0]
# print("Predictions {}".format(pred))
# print("Sum {}".format(np.sum(pred)))
#
# model.fit([board_l, next_player_l], reward_l, batch_size=None, steps_per_epoch=1, epochs=1)
print("Saving weights.")
model.save_weights("distribution.h5")

# preds = model.predict([board_l[:1], next_player_l[:1]])
# pred = preds[0]
# print("Predictions {}".format(pred))
# print("Sum {}".format(np.sum(pred)))

if save_coreml:
  coreml_model = coremltools.converters.keras.convert(
      model, input_names=["board", "next_player"],
      output_names=["distribution", "reward"])
  coreml_model.save("Distribution.mlmodel")
