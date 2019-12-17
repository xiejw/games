from game import Color

# This class assumes 'b' and 'w' play in turns. No passes.
#
# Not thread safe.
class ExperienceBuffer(object):

    def __init__(self):
        self._moves_and_rewards = []
        self._current_epoch_moves = []

    def start_epoch(self):
        assert not self._current_epoch_moves

    # Winner == Color.NA means a tie
    def end_epoch(self, winner):
        assert winner is not None
        if winner == Color.NA:
            for move in self._current_epoch_moves:
                self._moves_and_rewards.apppend(move, 0.0)
        else:
            black_reward = 1.0 if winner == Color.BLACK else -1.0
            white_reward = black_reward * -1.0
            for i, move in enumerate(self._current_epoch_moves):
                reward = black_reward if i % 2 == 0 else white_reward
                self._moves_and_rewards.append((move, reward))

        # Reset
        self._current_epoch_moves = []

    def add_move(self, move):
        self._current_epoch_moves.append(move)

    def report(self):
        for move, reward in self._moves_and_rewards:
            print("%s -> %s" % (move, reward))

