#!/bin/bash

set -e

attempts=3
num_hosts=100
tags="benchmark-notify-include-no-change benchmark-notify-no-include-no-change benchmark-notify-include-one-changed benchmark-notify-no-include-one-changed benchmark-notify-include-all-changed benchmark-notify-no-include-all-changed"
inventory=ansible/inventory/hosts-$num_hosts
playbook=ansible/benchmark-notify.yml
gathers="yes"
groups="yes"

for gather in $gathers; do
    for group in $groups; do
        output_dir=gather-$gather-group-$group
        mkdir -p $output_dir
        for tag in $tags ; do
            for i in $(seq 1 $attempts); do
                echo $tag [$i]
                (time ansible-playbook -i $inventory $playbook  --tags $tag -e gather_facts=$gather -e group_hosts=$group) &> $output_dir/$tag-$i-$num_hosts.log
            done;
        done
    done
done

