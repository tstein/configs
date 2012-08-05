#!/usr/bin/env python

import cPickle as pickle
from os import path, system
from subprocess import check_output


def main():
    pr = "purple-remote"
    oldstatus = check_output([pr, "getstatus"]).strip()
    oldmessage = check_output([pr, "getstatusmessage"]).strip()
    pckl = path.join(path.expanduser("~/.aura/tmp"), "pidgin_status.pickle")
    with open(pckl, "wb") as f:
        pickle.dump((oldstatus, oldmessage), f)
    # This is way less pain through purple-remote.
    cmd = pr + " \"setstatus?status=unavailable&message=\""
    system(cmd)

if __name__ == '__main__':
    main()

