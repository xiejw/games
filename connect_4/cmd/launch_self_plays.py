import subprocess
import random

from scheduler import Scheduler

LOG_FILE = '/tmp/scheduler.log'

## Launches the self_plays and attachs the logs to tee.
def launcher(global_index):
    # Writes the tee outputs to this file for audit.
    f = open(LOG_FILE, 'a')

    # Launches the self_plays immediately.
    job = subprocess.Popen(('unbuffer', 'make', 'self_plays'),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

    tee_job = subprocess.Popen(
            ('tee', '-a', '/tmp/self_plays_%s.log' % str(global_index)),
            stdin=job.stdout,
            stdout=f)

    return job

print("Please monitor logging at", LOG_FILE)
sch = Scheduler(launcher, total_jobs=3500, max_concurrent_jobs=20)
sch.run()
