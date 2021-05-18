#!/bin/bash

set -e

# Parameters
num_hosts="10 100 200"
num_vars="100 1000 10000"
var_len="1 100 1000"
attempts=3

playbook=$(pwd)/benchmarks/extra-vars/benchmark-extra-vars.yml
output_dir=$(pwd)/results
csv=$output_dir/benchmark-extra-vars.csv

function populate_extra_vars {
    local h=$1
    local f=$2
    local l=$3
    # Create a set of extra vars.
    mkdir -p extra_vars
    local var_value=$(head -c $l /dev/zero | tr '\0' '\141')
    python3 $top/tools/make-vars-yaml.py $f $var_value > extra_vars.yml
}

mkdir -p $output_dir
top=$(pwd)
pushd $(dirname $playbook)

echo "Hosts,Group vars,Var length,Attempt,Task duration,Playbook duration" > $csv

for h in $num_hosts; do
    inventory=$top/ansible/inventory/hosts-$h
    for f in $num_vars; do
        for l in $var_len; do
            populate_extra_vars $h $f $l
            for i in $(seq 1 $attempts); do
                file=$output_dir/benchmark-extra-vars-hosts-$h-vars-$f-len-$l-attempt-$i.log
                echo "Attempt [$i] -> $file"
                (time ansible-playbook -i $inventory -e @extra_vars.yml $(basename $playbook)) &> $file
                task_duration=$(awk '$1 == "Hello," { print $4 }' $file)
                task_duration=${task_duration%?}
                playbook_duration=$(awk '$1 == "real" { print $2 }' $file)
                echo "$h,$f,$l,$i,$task_duration,$playbook_duration" >> $csv
            done
        done
    done
done
