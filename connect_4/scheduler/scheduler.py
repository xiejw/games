import time


# A scheduler launches jobs in background.
#
# - This schduduler maintainces a pool of max of `max_concurrent_jobs` in total.
# - Periodically check finished jobs.
# - Launch new jobs toward both `max_concurrent_jobs` and `total_jobs`.
class Scheduler(object):

    def __init__(self, launcher, total_jobs, max_concurrent_jobs,
            sleep_secs=5, log_fn=print):
        self._launcher = launcher
        self._total_jobs = total_jobs
        self._max_concurrent_jobs = max_concurrent_jobs
        self._sleep_secs = sleep_secs
        self._log_fn = log_fn

    def run(self):

        total_jobs = self._total_jobs
        log_fn = self._log_fn
        num_concurrent_process = self._max_concurrent_jobs

        pool = []
        num_finished = 0
        global_id = 0

        while num_finished + len(pool) <= total_jobs:
            log_fn("== %d in pool, %d finished. Target for %d." % (
                len(pool), num_finished, total_jobs))

            log_fn("== Checking existing processes.")
            finished = []
            original_pool = pool
            pool = []
            for p in original_pool:
                if p.poll() is not None:
                    finished.append(p)
                else:
                    pool.append(p)
            log_fn("== Found %d finished job." % len(finished))
            num_finished += len(finished)

            if num_finished == total_jobs:
                assert len(pool) == 0
                log_fn("== Finished. Bye!!!")
                break

            launched = 0
            while (num_finished + len(pool) < total_jobs and
                    len(pool) < num_concurrent_process):
                new_p = self._launcher(global_id)
                global_id += 1
                pool.append(new_p)
                launched += 1
            log_fn("== Launched %d new jobs" % launched)


            log_fn("== Sleep for %d secs\n\n\n" % self._sleep_secs)
            time.sleep(self._sleep_secs)
