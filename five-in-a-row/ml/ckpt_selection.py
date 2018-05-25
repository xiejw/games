import glob
import random

_TOTAL_CKPT = 12
_TOP_K_CKPT = 4

ckpt_list = list(reversed(sorted(glob.glob('distribution-15*.h5'))))
top_k_list = ckpt_list[:_TOP_K_CKPT]
rest = ckpt_list[_TOP_K_CKPT:]
random.shuffle(rest)
rest = rest[:_TOTAL_CKPT - _TOP_K_CKPT]
rest = list(reversed(sorted(rest)))

for ckpt in top_k_list + rest:
    print ckpt
