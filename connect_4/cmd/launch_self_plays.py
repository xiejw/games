import subprocess
import random

from scheduler import Scheduler

def launcher(global_index):
    f = open('/tmp/scheduler.log', 'a')
    job = subprocess.Popen(('unbuffer', 'make', 'self_plays'),
            stdout=subprocess.PIPE,stderr=subprocess.PIPE)

    tee_job = subprocess.Popen(('tee', '-a', '/tmp/self_plays_%s.log' %
        str(global_index)),
        stdin=job.stdout, stdout=f)

    return job

sch = Scheduler(launcher, total_jobs=70, max_concurrent_jobs=70)
sch.run()
