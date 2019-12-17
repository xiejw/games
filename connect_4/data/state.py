from game import Color
from game import SnapshotView
from game import Position

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

    def to_str(self):
        return "%s@%s,%2.0f,%s" % (
                self.next_player_color,
                self.position,
                self.reward,
                self.snapshot)

# Alias for convenience.
State = TrainingState
