from .redis import get_redis_handler

_INT_TYPE = 0

_KEYS = [
        ('current_loop_index', _INT_TYPE),
        ('training_total_loops', _INT_TYPE),
        ('training_games_per_loop', _INT_TYPE),
        ('training_samples_per_game', _INT_TYPE),
]

def get_hparams():
    params_dict = {}

    r = get_redis_handler()

    for key_type_pair in _KEYS:
        key, type_id = key_type_pair
        v = r.get(key)
        if type_id == _INT_TYPE:
            params_dict[key] = int(v)
        else:
            raise TypeError('Unsupported type {}'.format(type_id))

    r.close()

    return params_dict

def set_hparams(params_dict):
    r = get_redis_handler()

    for key_type_pair in _KEYS:
        key, _ = key_type_pair
        v = params_dict.get(key)
        if v is None:
            raise RuntimeError('Key cannot be found in hparams: {}'.format(key))
        r.set(key, v)

    r.close()


