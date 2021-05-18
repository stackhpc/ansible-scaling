#!/usr/bin/env python3

import sys

num_groups = int(sys.argv[1])
print("[all-hosts]")
for group in range(num_groups):
    print("[group-{}:children]".format(group))
    print("all-hosts")
