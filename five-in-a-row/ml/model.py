import keras
from keras.models import Model
from keras.layers import Dense, Dropout, Flatten, Input, Concatenate
from keras.layers import Conv2D, MaxPooling2D

from keras import backend as K
assert K.image_data_format() != 'channels_first'

def create_model(boardSize):
    # Build model
    input_shape = (boardSize, boardSize, 1)

    input_layer = Input(shape=input_shape)
    board_layer = Conv2D(32, kernel_size=(3, 3), padding='same', activation='relu')(input_layer)
    board_layer = Conv2D(64, (3, 3), padding='same', activation='relu')(board_layer)
    board_layer = MaxPooling2D(pool_size=(2, 2))(board_layer)

    board_layer = Dropout(0.25)(board_layer)
    board_layer = Flatten()(board_layer)

    next_player_layer = Input(shape=(1,))

    middel_layer = Concatenate()([board_layer, next_player_layer])

    middel_layer = Dense(256, activation='relu')(middel_layer)
    middel_layer = Dropout(0.2)(middel_layer)
    middel_layer = Dense(256, activation='relu')(middel_layer)
    final_layer = Dropout(0.2)(middel_layer)

    probability_output_shape = boardSize * boardSize
    probability_output = Dense(
            probability_output_shape, activation='softmax', name='prob')(
                    final_layer)
    reward_output_layer = Dense(128, activation='relu')(final_layer)
    # Reward is [-1, 1], so tanh
    reward_output = Dense(1, activation='tanh', name='reward')(reward_output_layer)

    inputs = [input_layer, next_player_layer]
    outputs = [probability_output, reward_output]

    model = Model(inputs, outputs)

    model.compile(loss=['categorical_crossentropy', 'mse'], optimizer='adam')
    model.summary()
    return model
