import keras

from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D


def build_model(input_shape, num_classes):
    model = Sequential()
    model.add(Conv2D(32, kernel_size=(4, 4),
                     activation='relu',
                     padding='same',
                     input_shape=input_shape))
    model.add(Conv2D(64, (3, 3), padding='same', activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))
    model.add(Flatten())
    model.add(Dense(128, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(num_classes, activation='softmax'))

    def categorical_accuracy(y_true, y_pred):
        # We flipped the value for the position vector. So, use abshere.
        y_true = keras.backend.abs(y_true)
        return keras.metrics.categorical_accuracy(y_true, y_pred)

    model.compile(loss=keras.losses.categorical_crossentropy,
                  optimizer=keras.optimizers.SGD(lr=0.001, clipnorm=1.0),
                  metrics=[categorical_accuracy])

    return model
