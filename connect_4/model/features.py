import numpy as np

from game import Color
from game import Position


# Converts structured states to features.
def convert_states_to_model_features(config, states):
    rewards_np = np.zeros([len(states)])
    positions_np = np.zeros([len(states), config.rows * config.columns])

    # 3 is the number of feature planes.
    boards_np = np.zeros([len(states), 3, config.rows, config.columns])

    for i, state in enumerate(states):

        # Labels
        r = state.reward
        rewards_np[i] = r
        j = config.convert_position_to_index(state.position)
        positions_np[i][j] = 1.0 if r >= 0 else -1.0

        # Features
        if state.next_player_color == Color.BLACK:
            boards_np[i, 2, :, :] = 1.0

        snapshot = state.snapshot
        for x in range(config.rows):
            for y in range(config.columns):
                color = snapshot.get(Position(x, y))
                if color is None:
                    continue

                if color == Color.BLACK:
                    boards_np[i, 0, x, y] = 1.0
                else:
                    assert color == Color.WHITE
                    boards_np[i, 1, x, y] = 1.0

    # Puts channels at the end.
    boards_np = np.transpose(boards_np, [0, 2, 3, 1])

    return boards_np, (rewards_np, positions_np)
