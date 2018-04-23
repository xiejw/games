import numpy as np
import random

class Data(object):

    def __init__(self):
        self.board = []
        self.nplayer = []
        self.reward = []
        self.dist = []

    def append(self, board, nplayer, reward, dist):
        self.board.append(board)
        self.nplayer.append(nplayer)
        self.reward.append(reward)
        self.dist.append(dist)

    def get_board(self):
        return np.array(self.board)

    def get_nplayer(self):
        return np.array(self.nplayer)

    def get_reward(self):
        return np.array(self.reward)

    def get_dist(self):
        return np.array(self.dist)


class Dataset(object):

  def __init__(self, fname, boardSize, shuffle=True):
    self._fname = fname
    self._size = boardSize
    self._shuffle = shuffle

  def get_data(self):
    fname = self._fname

    with open(fname) as f:
      content = f.readlines()

    def parseLine(line):
      data = line.strip('\n').split(',')
      if not data:
        return None

      offset = 0
      reward = float(data[offset])
      offset += 1

      next_player = 1.0 if int(data[offset]) == 1 else -1.0
      offset += 1

      dist_str = data[offset]
      offset += 1

      dist = np.zeros((self._size * self._size,))
      # normalized
      tokens = dist_str.split('#')
      index = 0
      total_sum = 0.0
      while index < len(tokens):
          x = int(tokens[index])
          index += 1
          y = int(tokens[index])
          index += 1
          value = float(tokens[index])
          index += 1
          total_sum += value
          dist[x * self._size + y] = value

      dist /= total_sum

      boardRawData = data[offset:]
      board = np.zeros((self._size, self._size, 1))
      index = 0
      while index < len(boardRawData):
        x = int(boardRawData[index])
        index += 1
        y = int(boardRawData[index])
        index += 1
        player = int(boardRawData[index])
        index += 1

        player = 1.0 if player == 1 else -1.0
        board[x,y] = [player]
      return board, next_player, reward, dist

    train_data = Data()
    test_data = Data()

    if self._shuffle:
        random.shuffle(content)

    self.content = content
    test_num = int(len(content) * 0.2)

    for line in content[:test_num]:
      result = parseLine(line)
      board, nplayer, reward, dist = result
      test_data.append(board, nplayer, reward, dist)

    for line in content[test_num:]:
      result = parseLine(line)
      board, nplayer, reward, dist = result
      train_data.append(board, nplayer, reward, dist)

    return train_data, test_data

