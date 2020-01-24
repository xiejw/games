# Disable all warnings from TensorFlow.
#
# - The order to disable warnings matters.
#   - Disable future warnings.
#   - Disable deprecation warnings.
#   - Disable annoying warning and info in codebase.
#
# - For CPP side, set TF_CPP_MIN_LOG_LEVEL=3.
def suppress_tf_warning():

    import os
    os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

    import warnings
    with warnings.catch_warnings():
        warnings.filterwarnings("ignore",category=FutureWarning)

        from tensorflow.python.util import deprecation
        deprecation._PRINT_DEPRECATION_WARNINGS = False

        import tensorflow as tf

        tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)
