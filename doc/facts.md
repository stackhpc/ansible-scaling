# Facts

TODO:

* baseline performance without facts, group_vars, or groups

100 hosts, with & without facts, no group_vars:

Thursday 29 April 2021  12:29:49 +0100 (0:00:35.534)       0:02:20.549 ********
===============================================================================
Gather facts --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 98.97s
../roles/benchmark-facts : Hello, world ------------------------------------------------------------------------------------------------------------------------------------------------------------ 35.53s
../roles/benchmark-facts : Hello, world ------------------------------------------------------------------------------------------------------------------------------------------------------------- 5.69s

real    2m24.738s
user    9m11.302s
sys     3m0.309s

100 hosts, with & without facts, with group_vars:

Thursday 29 April 2021  12:35:21 +0100 (0:00:40.725)       0:02:51.090 ********
===============================================================================
Gather facts -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 117.57s
../roles/benchmark-facts : Hello, world ------------------------------------------------------------------------------------------------------------------------------------------------------------ 40.73s
../roles/benchmark-facts : Hello, world ------------------------------------------------------------------------------------------------------------------------------------------------------------ 12.08s

real    2m57.828s
user    10m20.346s
sys     3m27.496s