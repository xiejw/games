from game import Color

# This class assumes 'b' and 'w' play in turns.
#
# - No passes.
# - Not thread safe.
class ExperienceBuffer(object):

    def __init__(self, config):
        self._config = config
        self._states = []
        self._current_epoch_moves = []

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

        # Rewinds the play.
        b = config.new_board()
        for i, move in enumerate(self._current_epoch_moves):
            reward = black_reward if i % 2 == 0 else white_reward
            self._states.append((move, reward, b.snapshot()))
            b.new_move(move)

        # Reset
        self._current_epoch_moves = []

    def add_move(self, move):
        self._current_epoch_moves.append(move)

    def report(self):
        for move, reward, snapshot in self._states:
            print("%s,%2.0f,%s" % (move, reward, snapshot))

