import random

from data import InferenceState
from game import Color
from model import convert_inference_state_to_model_feature
from model import build_model

from .policy import Policy


# Default path to load weights
WEIGHTS_FILE = '.build/weights.h5'


# Builds a model and loads weights.
def _build_model(config):
    num_classes = config.rows * config.columns
    input_shape = (config.rows, config.columns, 3)
    m = build_model(input_shape, num_classes)
    print("Loading model from:", WEIGHTS_FILE)
    m.load_weights(WEIGHTS_FILE)
    return m


# Selects the action based on trained supervised model.
class ModelPolicy(Policy):

    def __init__(self, board, color, model=None, epsilon=None, name=None):
        self._board = board
        self._config = board.config
        self._color = Color.of(color)
        self._model = model or _build_model(self._config)
        self._epsilon = epsilon
        self.name = name if name else "model_" + color

    def next_position(self):
        b = self._board
        legal_positions = b.legal_positions()

        if not legal_positions:
            raise RuntimeError("Board is full. This is not allowed.")

        # Enable some exploration.
        if self._epsilon and random.random() <= self._epsilon:
            return random.choice(legal_positions)

        # Predicts the moves probability.
        pred = self._model.predict(
                convert_inference_state_to_model_feature(
                    self._config,
                    InferenceState(
                        config=self._config,
                        # We just need a view.
                        snapshot=b.snapshot(deepcopy=False),
                        next_player_color=self._color)))

        # If the model predicts two items, used the first one. The second one is
        # for value.
        if isinstance(pred, list):
            pred = pred[0]

        assert pred.shape == (1, self._config.rows * self._config.columns)
        pred = pred[0]  # Take the results.

        # Grabs the predicted probability and selects the best one.
        pos_prob_pairs = [(p, pred[self._config.convert_position_to_index(p)])
                for p in legal_positions]
        best_pair = max(pos_prob_pairs, key=lambda x: x[1])

        return best_pair[0]


