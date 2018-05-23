from model import create_model

import coremltools

import os

boardSize = 8

model = create_model(boardSize)

weights_file = os.environ['WEIGHTS']

print("Loading weights from", weights_file)
model.load_weights(weights_file)

print("Saving the old model as DistributionLastIteration.")
coreml_model = coremltools.converters.keras.convert(
  model, input_names=["board", "next_player"],
  output_names=["distribution", "reward"])
coreml_model.save("DistributionLastIteration.mlmodel")
