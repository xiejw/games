import numpy as np
import random

import coremltools
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D

from keras import backend as K
assert K.image_data_format() != 'channels_first'

# Global Configuration.
boardSize = 8
fname = "/Users/xiejw/Desktop/stage_1.txt"
epochs = 12
shortMode = False
save_coreml = True

class Dataset(object):

  def __init__(self, fname):
    self._fname = fname

  def get_data(self):
    fname = self._fname

    x_train = []
    y_train = []

    with open(fname) as f:
      content = f.readlines()
    random.shuffle(content)
    self.content = content

    def parseLine(line):
      data = line.strip('\n').split(',')
      if not data:
        return None

      win = int(data[0]) * 1.0
      boardRawData = data[1:]
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
      return win, board

    count = 1
    for line in content:
      result = parseLine(line)
      count += 1
      if shortMode and count >= 100:
        break
      if result is None:
        continue
      win, board = result
      x_train.append(board)
      y_train.append(win)

    return x_train, y_train

  def get_training_data(self):
    x_train, y_train = self.get_data()

    x_train = np.array(x_train)
    y_train = np.array(y_train)

    # Summary of the data.
    num_of_samples = len(x_train)
    num_of_winning = len([y for y in y_train if y == 1.0])
    print("Total samples ", num_of_samples)
    print("Total samples with winning: {} ({})".format(
      num_of_winning, num_of_winning * 1.0 / num_of_samples))

    num_of_test = int(0.2 * num_of_samples)

    x_test = x_train[:num_of_test]
    y_test = y_train[:num_of_test]
    x_train = x_train[num_of_test:]
    y_train = y_train[num_of_test:]

    num_of_winning_in_test = len([y for y in y_test if y == 1.0])

    print("Total test samples ", num_of_test)
    print("Total test samples with winning: {} ({})".format(
      num_of_winning_in_test, num_of_winning_in_test * 1.0 / num_of_test))
    return (x_train, y_train, x_test, y_test)


ds = Dataset(fname)
(x_train, y_train, x_test, y_test) = ds.get_training_data()


input_shape = (boardSize, boardSize, 1)

model = Sequential()
model.add(Conv2D(32, kernel_size=(3, 3), activation='relu',
                 input_shape=input_shape))
model.add(Conv2D(64, (3, 3), activation='relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.25))


model.add(Flatten())
model.add(Dense(256, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(1, activation='sigmoid'))
	# Compile model
model.compile(
    loss='binary_crossentropy',
    optimizer='adam', metrics=['accuracy'])

model.summary()

model.fit(x_train, y_train,
          batch_size=128,
          epochs=epochs,
          validation_data=(x_test, y_test))

predictions = model.predict(x_test[:10])
for index, pred in enumerate(predictions):
  print("P {} R {} L {}".format(
    pred, y_test[index], ds.content[index].strip("\n")))

if save_coreml:
  coreml_model = coremltools.converters.keras.convert(
      model, input_names="board",
      output_names="prob")
  coreml_model.save("board.mlmodel")
