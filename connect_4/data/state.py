from game import Color
from game import SnapshotView
from game import Position
from game import Move

class InferenceState(object):

    def __init__(self, config, snapshot, next_player_color):
        self.config = config

        self.snapshot = snapshot
        assert isinstance(snapshot, SnapshotView)

        self.next_player_color = next_player_color
        assert isinstance(next_player_color, Color)
        assert next_player_color != Color.NA


class TrainingState(InferenceState):

    def __init__(self, config, snapshot, next_player_color, position, reward):
        self.position = position
        assert isinstance(position, Position)

        self.reward = reward

        super(TrainingState, self).__init__(config, snapshot, next_player_color)

    def __str__(self):
        s = "%s_%2.0f_%s" % (
                Move(self.position, self.next_player_color),
                self.reward,
                self.snapshot)
        snapshot = TrainingState.parsing(self.config, s)
        assert snapshot.board_view() == self.snapshot.board_view()
        return s

    # reverse the logic in `to_str`.
    @staticmethod
    def parsing(config, state_str):
        results = state_str.split("_", 2)
        if len(results) == 3:
            move, reward, snapshot = results
        elif len(results) == 2:
            move, reward = results
            snapshot = ""
        else:
            raise AssertionError("State str representation is wrong. Got: %s",
                    results)
        return SnapshotView.parsing(config, snapshot)

# Alias for convenience.
State = TrainingState
