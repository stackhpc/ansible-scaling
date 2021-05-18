#!/usr/bin/env python3

import copy
import sys
import yaml

num_facts = int(sys.argv[1])
fact_value = yaml.safe_load(sys.argv[2])
facts = {"var_%d" % i: copy.copy(fact_value) for i in range(num_facts)}
yaml.dump(facts, sys.stdout, default_flow_style=False)
