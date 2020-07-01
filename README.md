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

## License

Apache 2.0

## Author information

* Mark Goddard (mark@stackhpc.com)
