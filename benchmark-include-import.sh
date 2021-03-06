#!/bin/bash

set -e

tags="benchmark-task-include benchmark-task-import benchmark-skipped-task-include benchmark-skipped-task-import benchmark-task-include-loop benchmark-skipped-task-include-loop benchmark-old-role-import benchmark-new-role-import benchmark-role-include-with-tasks-from"
inventory=ansible/inventory/hosts-100
playbook=ansible/benchmark-include-import.yml
gathers="yes"
groups="yes"

for gather in $gathers; do
    for group in $groups; do
        output_dir=gather-$gather-group-$group
        mkdir -p $output_dir
        for tag in $tags ; do
            for i in $(seq 1 3); do
                echo $tag [$i]
                (time ansible-playbook -i $inventory $playbook  --tags $tag -e gather_facts=$gather -e group_hosts=$group) &> $output_dir/$tag-$i.log
            done;
        done
    done
done
