#!/usr/bin/env python

import subprocess

BR = "br-int"
CMD = "ovs-ofctl"
SUB_ADD = "add-flow"
SUB_QRY = "dump-flows"
SUB_DEL = "del-flows"

ADD_FLOW = [CMD, SUB_ADD, BR]
QRY_FLOWS = [CMD, SUB_QRY, BR]
DEL_FLOWS = [CMD, SUB_DEL, BR]
UPDATE=False

subprocess.Popen(QRY_FLOWS)
with open('flows.txt') as f:
    for flow in f:
        if flow.strip() and not flow.startswith("#"):
            print "adding the flow: %s" % flow
            if not UPDATE:
                p = subprocess.Popen(DEL_FLOWS)
                UPDATE = True
            subprocess.Popen([CMD, SUB_ADD, BR, flow])

subprocess.Popen(QRY_FLOWS)
