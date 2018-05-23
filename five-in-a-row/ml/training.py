from dataset import Dataset
from model import create_model

import coremltools

# Global Configuration.
boardSize = 8
fname = "games.txt"

save_coreml = True
cont_training = True

# Get data
ds = Dataset(fname, boardSize, shuffle=True)
train_data, test_data = ds.get_data()

print("Training data: {}".format(len(train_data.get_reward())))
print("Test data: {}".format(len(test_data.get_reward())))

model = create_model(boardSize)

if cont_training:
  print("Loading weights.")
  model.load_weights("distribution.h5")

if save_coreml:
  print("Saving the old model as DistributionLastIteration.")
  coreml_model = coremltools.converters.keras.convert(
      model, input_names=["board", "next_player"],
      output_names=["distribution", "reward"])
  coreml_model.save("DistributionLastIteration.mlmodel")

model.fit(
        [train_data.get_board(), train_data.get_nplayer()],
        [train_data.get_dist(), train_data.get_reward()],
        batch_size=128, epochs=12,
        validation_data=(
            [test_data.get_board(), test_data.get_nplayer()],
            [test_data.get_dist(), test_data.get_reward()])
        )
print("Saving weights.")
model.save_weights("distribution.h5")

preds = model.predict([test_data.get_board()[:1], test_data.get_nplayer()[:1]])
print("Distribution {}".format(preds[0]))
print("Reward {}".format(preds[1]))
print("Actual Distribution {}".format(test_data.get_dist()[0]))
print("Actual Reward {}".format(test_data.get_reward()[1]))

if save_coreml:
  print("Saving the new model as Distribution.")
  coreml_model = coremltools.converters.keras.convert(
      model, input_names=["board", "next_player"],
      output_names=["distribution", "reward"])
  coreml_model.save("Distribution.mlmodel")
