#!/usr/bin/env python

import cPickle as pickle
from os import path, system
from socket import gethostname


def main():
    pr = "purple-remote"
    host = gethostname().split(".")[0]
    herestatus = "available"
    heremessage = host
    pckl = path.join(path.expanduser("~/.aura"), "pidgin_status.pickle")
    with open(pckl, "rb") as f:
        try:
            (herestatus, heremessage) = pickle.load(f)
        except:
            pass
    # This is way less pain through purple-remote.
    cmd = pr + " \"setstatus?status=%s&message=%s\""
    cmd = cmd % (herestatus, heremessage)
    system(cmd)

if __name__ == '__main__':
    main()

