from .human import HumanPolicy
# from .mcts import MTCSPolicy
from .model import ModelPolicy
from .random import RandomPolicy

# This must be inference mode not training or exploration mode.
BestPolicy = ModelPolicy
