import numpy as np
import random

import coremltools
from keras.models import Model
from keras.layers import Dense, Dropout, Flatten, Input
from keras.layers import Conv2D, MaxPooling2D

from keras import backend as K
assert K.image_data_format() != 'channels_first'

# Global Configuration.
boardSize = 8
fname = "/Users/xiejw/Desktop/games_200k.txt"
epochs = 12
shortMode = False

save_coreml = True
cont_training = True

class Dataset(object):

  def __init__(self, fname):
    self._fname = fname

  def get_data(self):
    fname = self._fname

    x_train = []
    y_black_train = []
    y_white_train = []

    with open(fname) as f:
      content = f.readlines()
    random.shuffle(content)
    self.content = content

    def parseLine(line):
      data = line.strip('\n').split(',')
      if not data:
        return None

      blackWin = data[0]
      whiteWin = data[1]
      boardRawData = data[2:]
      board = np.zeros((boardSize, boardSize, 1))
      index = 0
      while index < len(boardRawData):
        x = int(boardRawData[index])
        index += 1
        y = int(boardRawData[index])
        index += 1
        player = int(boardRawData[index])
        index += 1

        player = 1 if player == 1 else -1
        board[x,y] = [player]
      return blackWin, whiteWin, board

    count = 1
    for line in content:
      result = parseLine(line)
      count += 1
      if shortMode and count >= 100:
        break
      if result is None:
        continue
      blackWin, whiteWin, board = result
      x_train.append(board)
      y_black_train.append(blackWin)
      y_white_train.append(whiteWin)

    return x_train, y_black_train, y_white_train

  def get_training_data(self):
    x_train, y_black_train, y_white_train = self.get_data()

    x_train = np.array(x_train)
    y_black_train = np.array(y_black_train)
    y_white_train = np.array(y_white_train)

    # Summary of the data.
    num_of_samples = len(x_train)
    print("Total samples ", num_of_samples)

    num_of_test = int(0.2 * num_of_samples)

    x_test = x_train[:num_of_test]
    y_black_test = y_black_train[:num_of_test]
    y_white_test = y_white_train[:num_of_test]

    x_train = x_train[num_of_test:]
    y_black_train = y_black_train[num_of_test:]
    y_white_train = y_white_train[num_of_test:]

    print("Total test samples ", num_of_test)
    return (x_train, y_black_train, y_white_train,
            x_test, y_black_test, y_white_test)


ds = Dataset(fname)
(x_train, y_black_train, y_white_train, x_test, y_black_test, y_white_test) = ds.get_training_data()

input_shape = (boardSize, boardSize, 1)

input_layer = Input(shape=input_shape)

middel_layer = Conv2D(32, kernel_size=(3, 3), activation='relu')(input_layer)
middel_layer = Conv2D(64, (3, 3), activation='relu')(middel_layer)
middel_layer = MaxPooling2D(pool_size=(2, 2))(middel_layer)

middel_layer = Dropout(0.25)(middel_layer)
middel_layer = Flatten()(middel_layer)
middel_layer = Dense(256, activation='relu')(middel_layer)
middel_layer = Dropout(0.5)(middel_layer)

blackOutput = Dense(1, activation='sigmoid', name='black')(middel_layer)
whiteOutput = Dense(1, activation='sigmoid', name='white')(middel_layer)

model = Model(input_layer, [blackOutput, whiteOutput])
model.compile(
    loss=['mse', 'mse'], optimizer='adam')

model.summary()

if cont_training:
    print("Loading weights.")
    model.load_weights("model.h5")

model.fit(x_train,
          {'black': y_black_train, 'white': y_white_train},
          batch_size=128,
          epochs=epochs,
          validation_data=(
                  x_test,
                  {'black': y_black_test, 'white': y_white_test}))

black_predictions, white_predictions = model.predict(x_test[:10])
for index in range(10):
  print("P {} - {} R {} - {} L {}".format(
    black_predictions[index], white_predictions[index],
    y_black_test[index], y_white_test[index],
    ds.content[index].strip("\n")))

model.save_weights("model.h5")

if save_coreml:
  coreml_model = coremltools.converters.keras.convert(
      model, input_names="board",
      output_names=["black", "white"])
  coreml_model.save("WinnerPredictor.mlmodel")
