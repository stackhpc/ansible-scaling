#!/usr/bin/env python3

import json
import sys

num_facts = int(sys.argv[1])
fact_value = sys.argv[2]
facts = {"ansible_fact_%d" % i: fact_value for i in range(num_facts)}
json.dump(facts, sys.stdout)
