#!/bin/bash

set -e

# Parameters
num_hosts="10 100 200"
num_host_vars="10 100 1000 10000"
var_len="1 100 1000"
attempts=3

playbook=$(pwd)/benchmarks/host-vars/benchmark-host-vars.yml
output_dir=$(pwd)/results
csv=$output_dir/benchmark-host-vars.csv

function populate_host_vars {
    local h=$1
    local f=$2
    local l=$3
    host_vars=$top/ansible/inventory/host_vars
    # Create a set of dummy host-vars.
    mkdir -p $host_vars
    local var_value=$(head -c $l /dev/zero | tr '\0' '\141')
    python3 $top/tools/make-vars-yaml.py $f $var_value > $host_vars/host-vars-source

    # Populate fact cache with symlinks to dummy host-vars.
    for i in $(seq 1 $h); do
        host_vars_link=$host_vars/h$(printf %03d $i)
        if [[ -L $host_vars_link ]]; then
            unlink $host_vars_link
        fi
        ln -s $host_vars/host-vars-source $host_vars_link
    done
}

mkdir -p $output_dir
top=$(pwd)
pushd $(dirname $playbook)

echo "Hosts,Host vars,Host vars length,Attempt,Task duration,Playbook duration" > $csv

for h in $num_hosts; do
    inventory=$top/ansible/inventory/hosts-$h
    for f in $num_host_vars; do
        for l in $var_len; do
            populate_host_vars $h $f $l
            for i in $(seq 1 $attempts); do
                file=$output_dir/benchmark-host-vars-hosts-$h-host-vars-$f-len-$l-attempt-$i.log
                echo "Attempt [$i] -> $file"
                (time ansible-playbook -i $inventory $(basename $playbook)) &> $file
                task_duration=$(awk '$1 == "Hello," { print $4 }' $file)
                task_duration=${task_duration%?}
                playbook_duration=$(awk '$1 == "real" { print $2 }' $file)
                echo "$h,$f,$l,$i,$task_duration,$playbook_duration" >> $csv
            done
        done
    done
done
