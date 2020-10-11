import keras

from keras import backend as K
from keras.models import Model
from keras.layers import Input, Dense, Flatten, Add
from keras.layers import Conv2D, BatchNormalization, ReLU
from keras.regularizers import l2

L2_WEIGHT_DECAY = 1e-4


# Builds a multi-layer Residual network.
def build_resnet_model(input_shape, num_classes, num_layers=20):
    inp = Input(shape=input_shape)

    x = inp

    # Conv block
    x = Conv2D(128,
               kernel_size=(4, 4),
               padding='same',
               kernel_regularizer=l2(L2_WEIGHT_DECAY))(x)
    x = BatchNormalization()(x)
    x = ReLU()(x)

    # Residual blocks
    for _ in range(num_layers):
      x = build_residual_block(x)

    head_base = x
    del x

    # Build heads
    policy_head = build_policy_head(head_base, num_classes, head_name='policy')
    value_head = build_value_head(head_base, head_name='value')

    # Build model.
    model = Model(inputs=[inp], outputs=[policy_head, value_head])

    def abs_metrics(y_true, y_pred):
        return K.mean(K.abs(y_true - y_pred), axis=-1)

    model.compile(
        loss={'policy': 'categorical_crossentropy', 'value': 'mse'},
        optimizer=keras.optimizers.SGD(lr=0.001, momentum=0.9),
        metrics={'policy': 'categorical_accuracy', 'value' :abs_metrics})

    return model


def build_residual_block(inp):
    x = inp
    x = Conv2D(
            128,
            kernel_size=(4, 4),
            padding='same',
            kernel_regularizer=l2(L2_WEIGHT_DECAY))(x)
    x = BatchNormalization()(x)
    x = ReLU()(x)

    x = Conv2D(
            128,
            kernel_size=(4, 4),
            padding='same',
            kernel_regularizer=l2(L2_WEIGHT_DECAY))(x)
    x = BatchNormalization()(x)

    x = Add()([x, inp])
    x = ReLU()(x)

    return x


def build_policy_head(head_base, num_classes, head_name):
    x = Conv2D(
            2,
            kernel_size=(1, 1),
            padding='same',
            kernel_regularizer=l2(L2_WEIGHT_DECAY))(head_base)
    x = BatchNormalization()(x)
    x = ReLU()(x)
    x = Flatten()(x)

    policy_head = Dense(
        num_classes,
        activation='softmax',
        name=head_name,
        kernel_regularizer=l2(L2_WEIGHT_DECAY),
        bias_regularizer=l2(L2_WEIGHT_DECAY))(x)
    return policy_head


def build_value_head(head_base, head_name):
    x = Conv2D(
            2,
            kernel_size=(1, 1),
            padding='same',
            kernel_regularizer=l2(L2_WEIGHT_DECAY))(head_base)
    x = BatchNormalization()(x)
    x = ReLU()(x)
    x = Flatten()(x)
    x = Dense(
            256,
            activation='relu',
            kernel_regularizer=l2(L2_WEIGHT_DECAY),
            bias_regularizer=l2(L2_WEIGHT_DECAY))(x)

    value_head = Dense(
            1,
            activation='tanh',
            name=head_name,
            kernel_regularizer=l2(L2_WEIGHT_DECAY),
            bias_regularizer=l2(L2_WEIGHT_DECAY))(x)
    return value_head
