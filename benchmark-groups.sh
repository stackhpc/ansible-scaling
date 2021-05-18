#!/bin/bash

set -e

# Parameters
num_hosts="10 100 200"
num_groups="10 100 1000 10000"
attempts=3

playbook=$(pwd)/benchmarks/groups/benchmark-groups.yml
output_dir=$(pwd)/results
csv=$output_dir/benchmark-groups.csv

function populate_groups {
    local g=$1
    # Create a set of groups
    python3 $top/tools/make-groups.py $g > inventory/groups
}

mkdir -p $output_dir
top=$(pwd)
pushd $(dirname $playbook)

echo "Hosts,Group,Attempt,Task duration,Playbook duration" > $csv

for h in $num_hosts; do
    inventory=inventory/hosts-$h
    for g in $num_groups; do
        populate_groups $g
        groups=inventory/groups
        for i in $(seq 1 $attempts); do
            file=$output_dir/benchmark-groups-hosts-$h-groups-$g-attempt-$i.log
            echo "Attempt [$i] -> $file"
            (time ansible-playbook -i $inventory -i $groups $(basename $playbook)) &> $file
            task_duration=$(awk '$1 == "Hello," { print $4 }' $file)
            task_duration=${task_duration%?}
            playbook_duration=$(awk '$1 == "real" { print $2 }' $file)
            echo "$h,$g,$i,$task_duration,$playbook_duration" >> $csv
        done
    done
done
