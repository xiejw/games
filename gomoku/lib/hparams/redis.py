# https://github.com/andymccurdy/redis-py
import redis

_PORT = 6380

# This is designed for one time usage. So close it after usage.
def get_redis_handler():
    r = redis.Redis(host='localhost', port=_PORT, db=0)
    return r

