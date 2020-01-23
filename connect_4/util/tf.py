# Disable all warnings from TensorFlow (Python side).
#
# - The order to disable warnings matters.
# - For CPP side, set # TF_CPP_MIN_LOG_LEVEL=3.
def suppress_tf_warning():

    import os
    os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

    import warnings
    with warnings.catch_warnings():
        warnings.filterwarnings("ignore",category=FutureWarning)

        from tensorflow.python.util import deprecation
        deprecation._PRINT_DEPRECATION_WARNINGS = False

        import tensorflow as tf

        # In addition, disable warning logging.
        tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)

        from tensorflow import keras
