# Include and import

Playbook: [benchmark-include-import.yml](ansible/benchmark-include-import.yml)

Inventory: [hosts-100](ansible/inventory/hosts-100)

The script [benchmark-include-import.sh](benchmark-include-import.sh) executes
each benchmark 3 times.

The [hello.yml](ansible/roles/benchmark-include-import/tasks/hello.yml) tasks
file executes the debug module once.  The
[hello-4x.yml](ansible/roles/benchmark-include-import/tasks/hello-4x.yml)
tasks file executes the debug module four times.

## Task include and import

In these benchmarks we compare `include_tasks` with `import_tasks`.

* `benchmark-task-include`: include `hello.yml` four times
* `benchmark-task-import`: import `hello.yml` four times

Results:

```
benchmark-task-import-1.log:real	0m55.282s
benchmark-task-import-2.log:real	0m55.909s
benchmark-task-import-3.log:real	0m55.892s
benchmark-task-include-1.log:real	1m20.631s
benchmark-task-include-2.log:real	1m23.109s
benchmark-task-include-3.log:real	1m18.206s
```

Clearly, there is a significant overhead to using dynamic task inclusion with
many hosts.

## Skipped task include and import

Here we compare the overhead of `include_tasks` with `import_tasks`, when the
tasks are skipped.

* `benchmark-skipped-task-include`: include `hello-4x.yml`, skipped
* `benchmark-skipped-task-import`: import `hello-4x.yml`, skipped

Results:

```
benchmark-skipped-task-import-1.log:real	1m1.052s
benchmark-skipped-task-import-2.log:real	1m33.250s
benchmark-skipped-task-import-3.log:real	0m57.327s
benchmark-skipped-task-include-1.log:real	0m44.592s
benchmark-skipped-task-include-2.log:real	0m46.521s
benchmark-skipped-task-include-3.log:real	0m52.486s
```

In this case, the include is faster, due to the overhead of skipping four tasks
rather than one (the include task).

## Task include loops and skipping

Here we compare the use of `include_tasks` in a loop, when the task is skipped.

* `benchmark-task-include-loop`: include `hello.yml` four times in a loop
* `benchmark-skipped-task-include-loop`: include `hello.yml` four times in a loop, skipped

Results:

```
benchmark-skipped-task-include-loop-1.log:real	0m37.409s
benchmark-skipped-task-include-loop-2.log:real	0m37.789s
benchmark-skipped-task-include-loop-3.log:real	0m37.728s
benchmark-task-include-loop-1.log:real	0m55.315s
benchmark-task-include-loop-2.log:real	0m53.904s
benchmark-task-include-loop-3.log:real	0m54.596s
```

We see that there is overhead to each include, but when the task is skipped,
this does not apply beyond the normal overhead of a skipped task.

## Role include and import

The following tags compare different ways to dynamically include a task file
from within a role. This pattern is used extensively within Kolla Ansible.
We compare `roles` with `include_role` and `import_role`. The following tags
can be used to match each benchmark.

* `benchmark-old-role-import`: Old style `roles` section, `include_tasks` in the role
* `benchmark-new-role-import`: `import_role`, `include_tasks` in the role
* `benchmark-role-include-with-tasks-from`: `include_role`, with `tasks_from`

Results:

```
benchmark-old-role-import-1.log:real	0m58.518s
benchmark-old-role-import-3.log:real	0m57.847s
benchmark-old-role-import-2.log:real	0m51.817s
benchmark-new-role-import-1.log:real	0m50.523s
benchmark-new-role-import-2.log:real	0m54.433s
benchmark-new-role-import-3.log:real	0m50.512s
benchmark-role-include-with-tasks-from-3.log:real	0m59.795s
benchmark-role-include-with-tasks-from-1.log:real	0m52.262s
benchmark-role-include-with-tasks-from-2.log:real	0m51.508s
```

Here it is hard to see much difference between the methods.
