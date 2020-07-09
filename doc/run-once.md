# Run once

Playbook: [benchmark-run-once.yml](../ansible/benchmark-run-once.yml)

Inventory: [hosts-100](../ansible/inventory/hosts-100)

The script [benchmark-run-once.sh](../benchmark-run-once.sh) executes each
benchmark 3 times.

## Run once yes

This benchmark executes a debug task with `run_once`.

Results:

```
benchmark-run-once-yes-1.log:real	0m34.943s
benchmark-run-once-yes-2.log:real	0m35.835s
benchmark-run-once-yes-3.log:real	0m34.509s
```

## Run once no, skipped

This benchmark executes a debug task without `run_once` which is skipped for
all hosts.

Results:

```
benchmark-run-once-no-skipped-1.log:real	0m38.356s
benchmark-run-once-no-skipped-2.log:real	0m38.633s
benchmark-run-once-no-skipped-3.log:real	0m37.487s
```

## Conclusions

The `run_once` flag reduces the time taken to execute a task when compared with
skipping the task for all but one host.
