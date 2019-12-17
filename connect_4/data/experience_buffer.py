from game import Color

from .state import State

# This class assumes 'b' and 'w' play in turns.
#
# - `writer`:Fn(string) if not None, takes a string.
# - No passes.
# - Not thread safe.
class ExperienceBuffer(object):

    def __init__(self, config, writer=None):
        self._config = config
        self._states = []
        self._current_epoch_moves = []
        self._writer = writer

    def start_epoch(self):
        assert not self._current_epoch_moves

    # Ends the current epoch.
    #
    # winner == Color.NA means a tie
    def end_epoch(self, winner):
        assert winner is not None
        config = self._config

        if winner == Color.NA:
            black_reward = 0.0
            white_reward = 0.0
        else:
            black_reward = 1.0 if winner == Color.BLACK else -1.0
            white_reward = black_reward * -1.0

        # Replay the epoch.
        b = config.new_board()
        for i, move in enumerate(self._current_epoch_moves):
            reward = black_reward if i % 2 == 0 else white_reward
            state = State(
                    config=self._config,
                    snapshot=b.snapshot(),
                    next_player_color=move.color,
                    position=move.position,
                    reward=reward)
            self._states.append(state)
            b.new_move(move)  # Mutate the board

        # Reset
        self._current_epoch_moves = []

    def add_move(self, move):
        self._current_epoch_moves.append(move)

    def report(self):
        writer = self._writer if self._writer else print
        for state in self._states:
            writer(state.to_str())

        # Reset
        self._states = []

