import random
import math

from data import InferenceState
from game import Color
from game import Position
from model import build_model
from model import convert_inference_states_to_model_feature

from .policy import Policy


class MCTSNode(object):

    def __init__(self, board, next_player_color, model):
        self.board = board
        self._config = board.config
        self.next_player_color = next_player_color
        self.model = model

        self.legal_positions = board.legal_positions()
        if not self.legal_positions:
            raise RuntimeError("N/A")

        self.total_count = 0

        self.n = {}
        self.w = {}
        self.p = {}

        pred = self.model.predict(
                convert_inference_states_to_model_feature(
                    self._config,
                    InferenceState(
                        config=self._config,
                        # One-time purpose.
                        snapshot=board.snapshot(deepcopy=False),
                        next_player_color=self.color)))

        for pos in self.legal_positions:
            index = self._config.convert_position_to_index(pos)
            self.p[pos] = pred[0][0][index]
            self.n[pos] = 0

    def backup(self, pos, value):
        self.total_count += 1
        self.n[pos] += 1
        self.w[pos] += value

    # Selects a node based on current simulation results.
    def select(self):
        assert self.total_count > 0

        c = 1.0
        q = {}

        sqrt_total_count = math.sqrt(self.total_count)
        for pos in self.legal_positions:
            n = self.n[pos]
            q[pos] = self.w[pos] / (n if n else 1)
            q[pos] += c * self.p[pos] * sqrt_total_count / (1.0 + self.n[pos])

        # TODO: Allows exploration.
        max_pos = max(q, key=lambda k: q[k])
        return max_pos

    def simulate(self, iterations=1600):
        pass

        # loop `iterations`.
        #   while True
        #     select an action.
        #     gets children of the node
        #     if new child:
        #       backup
        #       break

        debug = print

        for i in range(iterations):
            debug("=== iteration i")



class MCTSPolicy(Policy):


    def __init__(self, board, color, model=None, name=None):
        self._board = board
        self._config = board.config
        self._color = Color.of(color)
        self._model = model or _build_model(self._config)
        self.name = name if name else "model_" + color

        self._tree = {}

    def next_position(self):
      # promot next node
      # simulation.
      # select
