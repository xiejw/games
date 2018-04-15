import numpy as np
import random

class Dataset(object):

  def __init__(self, fname, boardSize, shortMode):
    self._fname = fname
    self._size = boardSize
    self._shortMode = shortMode

  def get_data(self):
    fname = self._fname

    with open(fname) as f:
      content = f.readlines()
    random.shuffle(content)
    self.content = content

    def parseLine(line):
      data = line.strip('\n').split(',')
      if not data:
        return None

      # Reward(F), NextPlayer(I), MoveX(I), MoveY(I), Board

      offset = 0
      reward = float(data[offset])
      offset += 1

      next_player = 1.0 if int(data[offset]) == 1 else -1.0
      offset += 1

      move_x = int(data[offset])
      offset += 1

      move_y = int(data[offset])
      offset += 1

      reward_vec = np.zeros((self._size * self._size,))
      reward_vec[move_x * self._size + move_y] = reward

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
      return  board, next_player, reward_vec

    board_l = []
    next_player_l = []
    reward_l = []

    count = 1
    for line in content:
      result = parseLine(line)
      count += 1
      if self._shortMode and count >= 100:
        break
      if result is None:
        continue
      board, next_player, reward_vec = result
      board_l.append(board)
      next_player_l.append(next_player)
      reward_l.append(reward_vec)

    board_l = np.array(board_l)
    next_player_l = np.array(next_player_l)
    reward_l = np.array(reward_l)
    return board_l, next_player_l, reward_l
