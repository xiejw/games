from .redis import get_redis_handler

def get_hparams():
    params_dict = {}

    r = get_redis_handler()
    params_dict['training_total_loops'] = int(r.get('training_total_loops'))
    r.close()

    return params_dict

def set_hparams(params_dict):
    r = get_redis_handler()
    r.set('training_total_loops', params_dict['training_total_loops'])
    r.close()


