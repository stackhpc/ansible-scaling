# Skip

What we are trying to do with these benchmarks is to determine the cost of
various ways of executing tasks conditionally on different hosts.

Playbook: [benchmark-skip.yml](ansible/benchmark-skip.yml)

Inventory: [hosts-100](ansible/inventory/hosts-100)

The script [benchmark-run-once.sh](benchmark-skip.sh) executes each benchmark 3
times.

Individual task durations have been included since they are short comparison
with the total play execution time.

## Not skipped

This benchmark executes a debug task.

Total:

```
benchmark-not-skipped-1.log:real	0m38.215s
benchmark-not-skipped-2.log:real	0m37.495s
benchmark-not-skipped-3.log:real	0m38.282s
```

Task:

```
benchmark-not-skipped-1.log 3.14s
benchmark-not-skipped-2.log 3.08s
benchmark-not-skipped-3.log 3.32s
```

## Skipped

This benchmark executes a debug task that is skipped.

Total:

```
benchmark-skipped-1.log:real	0m37.759s
benchmark-skipped-2.log:real	0m39.513s
benchmark-skipped-3.log:real	0m39.295s
```

Task:

```
benchmark-skipped-1.log 3.11s
benchmark-skipped-2.log 3.09s
benchmark-skipped-3.log 3.21s
```

## Not skipped 4x

This benchmark executes four debug tasks.

Total:

```
benchmark-not-skipped-4x-1.log:real	0m48.887s
benchmark-not-skipped-4x-2.log:real	0m47.370s
benchmark-not-skipped-4x-3.log:real	0m47.455s
```

Task:

```
benchmark-not-skipped-4x-1.log 3.10s
benchmark-not-skipped-4x-1.log 3.13s
benchmark-not-skipped-4x-1.log 3.18s
benchmark-not-skipped-4x-1.log 3.20s
benchmark-not-skipped-4x-2.log 3.03s
benchmark-not-skipped-4x-2.log 3.08s
benchmark-not-skipped-4x-2.log 3.11s
benchmark-not-skipped-4x-2.log 3.12s
benchmark-not-skipped-4x-3.log 3.08s
benchmark-not-skipped-4x-3.log 3.12s
benchmark-not-skipped-4x-3.log 3.23s
benchmark-not-skipped-4x-3.log 3.25s
```

## Skipped 4x

This benchmark executes four debug tasks that are skipped.

Total:

```
benchmark-skipped-4x-1.log:real	0m47.083s
benchmark-skipped-4x-2.log:real	0m48.043s
benchmark-skipped-4x-3.log:real	0m47.210s
```

Task:

```
benchmark-skipped-4x-1.log 3.03s
benchmark-skipped-4x-1.log 3.07s
benchmark-skipped-4x-1.log 3.11s
benchmark-skipped-4x-1.log 3.13s
benchmark-skipped-4x-2.log 3.04s
benchmark-skipped-4x-2.log 3.05s
benchmark-skipped-4x-2.log 3.10s
benchmark-skipped-4x-2.log 3.17s
benchmark-skipped-4x-3.log 2.81s
benchmark-skipped-4x-3.log 2.87s
benchmark-skipped-4x-3.log 2.93s
benchmark-skipped-4x-3.log 2.96s
```

## Not skipped loop

This benchmark executes multiple (20) debug tasks in a loop.

Total:

```
benchmark-not-skipped-loop-4x-1.log:real	0m48.094s
benchmark-not-skipped-loop-4x-2.log:real	0m44.875s
benchmark-not-skipped-loop-4x-3.log:real	0m42.589s
```

Task:

```
benchmark-not-skipped-loop-1.log 6.41s
benchmark-not-skipped-loop-2.log 5.94s
benchmark-not-skipped-loop-3.log 5.93s
```

## Skipped loop

This benchmark executes multiple (20) debug tasks in a loop that are skipped.

Total:

```
benchmark-skipped-loop-4x-1.log:real	0m41.953s
benchmark-skipped-loop-4x-2.log:real	0m43.032s
benchmark-skipped-loop-4x-3.log:real	0m42.308s
```

Task:

```
benchmark-skipped-loop-1.log 5.19s
benchmark-skipped-loop-2.log 5.15s
benchmark-skipped-loop-3.log 5.21s
```

## Empty loop

This benchmark executes a debug task in a loop over zero items.

Total:

```
benchmark-empty-loop-1.log:real	0m38.429s
benchmark-empty-loop-2.log:real	0m41.067s
benchmark-empty-loop-3.log:real	0m40.741s
```

Task:

```
benchmark-empty-loop-1.log 3.06s
benchmark-empty-loop-2.log 3.03s
benchmark-empty-loop-3.log 2.98s
```

## Conclusions

We can see from these benchmarks that skipped tasks still incur some overhead.
When using a local action such as debug there is very little difference in task
duration between when the task is skipped and not.

Executing tasks in a loop may have a lower overhead than multiple separate
tasks. This is likely due to loops being executed inside a single Ansible fork,
avoiding process creation overheads. This difference may be less visible when
using remote task execution.

Executing multiple skipped tasks in a loop is faster than executing the debug
module in a loop. Executing an empty loop is faster still. We might take from
this that it is more efficient to filter down a loop than to skip items:

```
with_items: "{{ [0, 1, 2, 3] }}"
when: item is odd
```

vs.

```
with_items: "{{ [0, 1, 2, 3] | select('odd') | list }}"
```

The fastest way to skip a task is to not execute it at all. If there are many
skipped tasks, consider whether your plays should be more granular.
