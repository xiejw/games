import subprocess
import random

from scheduler import Scheduler


## Launches the self_plays and attachs the logs to tee.
def launcher(global_index):
    # Writes the tee outputs to this file for audit.
    f = open('/tmp/scheduler.log', 'a')

    # Launches the self_plays immediately.
    job = subprocess.Popen(('unbuffer', 'make', 'self_plays'),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

    tee_job = subprocess.Popen(
            ('tee', '-a', '/tmp/self_plays_%s.log' % str(global_index)),
            stdin=job.stdout,
            stdout=f)

    return job

sch = Scheduler(launcher, total_jobs=70, max_concurrent_jobs=70)
sch.run()
