import keras

from keras.models import Model
from keras.layers import Input, Dense, Dropout, Flatten, BatchNormalization, ReLU
from keras.layers import Conv2D, Add
from keras import backend as K

def build_resnet_model(input_shape, num_classes):
    inp = Input(shape=input_shape)

    x = inp

    x = Conv2D(128, kernel_size=(4, 4), padding='same')(x)
    x = BatchNormalization()(x)
    x = ReLU()(x)

    for _ in range(5):
      x = res_block(x)

    head_base = x
    del x

    # Policy Head
    x = Conv2D(2, kernel_size=(1, 1), padding='same')(head_base)
    x = BatchNormalization()(x)
    x = ReLU()(x)
    x = Flatten()(x)
    policy_head = Dense(num_classes, activation='softmax', name='policy')(x)
    del x

    # Value Head
    x = Conv2D(2, kernel_size=(1, 1), padding='same')(head_base)
    x = BatchNormalization()(x)
    x = ReLU()(x)
    x = Flatten()(x)
    x = Dense(256, activation='relu')(x)
    value_head = Dense(1, activation='tanh', name='value')(x)
    del x


    model = Model(inputs=[inp], outputs=[policy_head, value_head])

    def abs_metrics(y_true, y_pred):
        return K.mean(K.abs(y_true - y_pred), axis=-1)


    model.compile(
        loss={'policy': 'categorical_crossentropy', 'value': 'mse'},
        optimizer=keras.optimizers.SGD(lr=0.001, momentum=0.9),
        metrics={'policy': 'categorical_accuracy', 'value' :abs_metrics})

    return model

def res_block(x):
    y = x
    x = Conv2D(128, kernel_size=(4, 4), padding='same')(x)
    x = BatchNormalization()(x)
    x = ReLU()(x)

    x = Conv2D(128, kernel_size=(4, 4), padding='same')(x)
    x = BatchNormalization()(x)
    x = Add()([x, y])

    x = ReLU()(x)

    return x

