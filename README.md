# Ansible Scaling

This repository includes scripts and playbooks to test and benchmark Ansible at
scale.

## Context

This is targeted at profiling for Kayobe and Kolla Ansible, but the insights
will be generally useful for large scale Ansible use. No real hosts are used -
only local tasks are benchmarked. This allows us to test how inventories of
various sizes affect Ansible controller performance.

## Benchmarks

Documentation and results of benchmarks are provided [here](doc/index.md).

## Tools

### profile\_tasks parser

[profile parser](tools/profile-parser.py) parses the output of the
[profile_tasks](https://docs.ansible.com/ansible/latest/plugins/callback/profile_tasks.html)
callback plugin and generates CSV data. It's not pretty, but it is effective if
this is the only data you have access to.

### profile\_tasks massager

[profile massager](tools/profile-massager.py) massages the CSV data generated
by the profile parser, into various formats. It aggregates based on task
duration, and allows filtering by play, role or task state.

## License

Apache 2.0

## Author information

* Mark Goddard (mark@stackhpc.com)
