from .features import convert_states_to_model_features
from .features import convert_inference_state_to_model_feature

from .cnn import build_cnn_model
from .resnet import build_resnet_model

# Inputs are (input_shape, num_classes)
build_model = build_resnet_model
