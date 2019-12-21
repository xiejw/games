import random

from data import InferenceState
from game import Color
from game import Position
from model import build_model
from model import convert_inference_states_to_model_feature

from .policy import Policy


WEIGHTS_FILE = '.build/weights.h5'


def _build_model(config):
    num_classes = config.rows * config.columns
    input_shape = (config.rows, config.columns, 3)
    m = build_model(input_shape, num_classes)
    print("Loading model from:", WEIGHTS_FILE)
    m.load_weights(WEIGHTS_FILE)
    return m


# Select the action based on model.
class ModelPolicy(Policy):

    def __init__(self, board, color, model=None, epsilon=0.1, name=None):
        self._board = board
        self._config = board.config
        self._color = Color.of(color)
        self._model = model or _build_model(self._config)
        self._epsilon = epsilon
        self.name = name if name else "model_" + color

    def next_position(self):
        b = self._board
        legal_moves = b.legal_moves()

        if not legal_moves:
            raise RuntimeError("N/A")

        if random.random() <= self._epsilon:
            return random.choice(legal_moves)

        pred = self._model.predict(
                convert_inference_states_to_model_feature(
                    self._config,
                    InferenceState(
                        config=self._config,
                        snapshot=b.snapshot(deepcopy=False),
                        next_player_color=self._color)))

        probs = [(p, pred[0][self._config.convert_position_to_index(p)]) for p in
                legal_moves]
        max_position = max(probs, key=lambda x: x[1])

        return max_position[0]

