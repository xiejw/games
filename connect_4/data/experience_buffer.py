
# This class assumes 'b' and 'w' play in turns. No passes.
class ExperienceBuffer(object):

    def __init__(self):
        self._moves = []
        self._current_epoch_moves = []

    def start_epoch(self):
        pass

    # Winner == None means a tie
    def end_epoch(self, winner):
        assert winner is not None

    def add_move(self, position_pair, color):
        pass

