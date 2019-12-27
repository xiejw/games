import subprocess
import time
import random

num_concurrent_process = 40
total_process = 100
sleep_secs = 5

pool = []
num_finished = 0

def launcher():
    secs = int(random.random() * 20) + 10
    args = ['sleep', str(secs)]
    return subprocess.Popen(args)

while num_finished + len(pool) <= total_process:
    print("== %d in pool, %d finished. Target for %d." % (
        len(pool), num_finished, total_process))

    print("== Checking existing processes.")
    finished = []
    original_pool = pool
    pool = []
    for p in original_pool:
        if p.poll() is not None:
            finished.append(p)
        else:
            pool.append(p)
    print("== Found %d finished job." % len(finished))
    num_finished += len(finished)

    if num_finished == total_process:
        assert len(pool) == 0
        print("== Finished. Bye!!!")
        break

    launched = 0
    while (num_finished + len(pool) < total_process and
            len(pool) < num_concurrent_process):
        new_p = launcher()
        pool.append(new_p)
        launched += 1
    print("== Launched %d new jobs" % launched)


    print("== Sleep for %d secs\n\n\n" % sleep_secs)
    time.sleep(sleep_secs)
