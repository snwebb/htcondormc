
error   = err.$(Process)                                                
output  = out.$(Process)                                                
log     = foo.log

queue 1


import os
import htcondor
pjoin = os.path.join
schedd = htcondor.Schedd()

events_per_job = 10
njobs = 2

topdir = str(Path(__file__).absolute().dir())
path_to_fragment = pjoin(topdir, "fragments", "ggh_m70_cfg.py")


output_path = pjoin("./output", tag)
if not os.path.exists(output_path):
    os.makedirs(output_path)



arguments = [path_to_fragment, events_per_job, n_threads, output_path]

sub = htcondor.Submit({
        "executable": pjoin(topdir, "run_wmLHEGS_DRPremix_Autumn18.sh")
        # "getenv" : "true",
        "arguments": " ".join([str(arg) for arg in arguments])
        "log" : "/dev/null",
        error = pjoin(output_path,  "err.$(Process)")
        output = pjoin(output_path,  "out.$(Process)")
        })

with schedd.transaction() as txn:
    print(sub.queue(txn, njobs))