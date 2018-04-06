import numpy as np
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D

from keras import backend as K
assert K.image_data_format() != 'channels_first'

boardSize = 8
fname = "/Users/xiejw/Desktop/stage_1.txt"
shortMode = True

def getTrainingData(fname):

  x_train = []
  y_train = []

  with open(fname) as f:
    content = f.readlines()

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

x_train, y_train = getTrainingData(fname)

x_train = np.array(x_train)
y_train = np.array(y_train)

x_test = x_train[:10]
y_test = y_train[:10]
x_train = x_train[10:]
y_train = y_train[10:]

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
          epochs=12,
          validation_data=(x_test, y_test))

result = model.predict(x=x_train[0:10])
for index in range(10):
  print('P {}  R {}'.format(result[index], y_train[index]))
