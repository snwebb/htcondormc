#!/usr/bin/env python

import os
import htcondor
from pathlib import Path

pjoin = os.path.join

tag = "ggh_m70"
events_per_job = 5
njobs = 1
n_threads = 1
topdir = os.path.dirname(str(Path(__file__).absolute()))
path_to_fragment = pjoin(topdir, "fragments", "ggh_m70_cfg.py")


output_path = os.path.abspath(pjoin("./output", tag))
if not os.path.exists(output_path):
    os.makedirs(output_path)



arguments = [path_to_fragment, events_per_job, n_threads, output_path]


executable = pjoin(topdir, "run_wmLHEGS_DRPremix_Autumn18.sh")


# sub = htcondor.Submit({
#         "universe" : "vanilla",
#         "should_transfer_files" : "YES",
#         "transfer_input_files" : executable,
#         "transfer_output_files" : "out1.txt",
#         "when_to_transfer_output" : "ON_EXIT",
#         "notification" : "NEVER",
#         "initialdir" : ".",
#         "executable": os.path.basename(executable),
#         "requirements" : '(OpSysAndVer =?= "CentOS7")',
#         "+MaxRuntime" : "60",
#         "RequestCPUs" : "1",
#         "getenv" : "true",
#         "arguments": ", ".join([str(arg) for arg in arguments]),
#         # "transfer_output_files" : "out1.root, out2.root",
#         "log" : "/dev/null",
#         # "error" : "err.$(Process)",
#         # "output" : "out.$(Process)"
#         })

mydict = {
"executable" : "/afs/cern.ch/work/a/aalbert/public/2019-06-07_lowmassdiphoton/htcondormc/run_wmLHEGS_DRPremix_Autumn18.sh",
"output" : "out1.root",
"error" : "err.$(Cluster).$(Process)",
"log" : "log.$(Cluster).$(Process)",
"arguments" : "/afs/cern.ch/work/a/aalbert/public/2019-06-07_lowmassdiphoton/htcondormc/fragments/ggh_m70_cfg.py, 1, 1, /afs/cern.ch/work/a/aalbert/public/2019-06-07_lowmassdiphoton/htcondormc/output",
"should_transfer_files" : "YES",
"when_to_transfer_output" : "ON_EXIT",
"Universe" : "vanilla",
"notification" : "Never",
"Initialdir" : ".",
"getenv" : "True",
}

sub = htcondor.Submit(mydict)

schedd = htcondor.Schedd()
with schedd.transaction() as txn:
    print(sub.queue(txn, njobs))
