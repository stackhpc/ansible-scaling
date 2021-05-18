#!/bin/bash

set -e

# Parameters
num_hosts="10 100 200"
num_vars="100 1000 10000"
var_len="1 100 1000"
attempts=3

playbook=$(pwd)/benchmarks/role-defaults/benchmark-role-defaults.yml
output_dir=$(pwd)/results
csv=$output_dir/benchmark-role-defaults.csv

function populate_role_defaults {
    local h=$1
    local f=$2
    local l=$3
    # Create a set of role defaults.
    mkdir -p roles/benchmark-role-defaults/defaults
    local var_value=$(head -c $l /dev/zero | tr '\0' '\141')
    python3 $top/tools/make-vars-yaml.py $f $var_value > roles/benchmark-role-defaults/defaults/main.yml
}

mkdir -p $output_dir
top=$(pwd)
pushd $(dirname $playbook)

echo "Hosts,Role defaults,Var length,Attempt,Task duration,Playbook duration" > $csv

for h in $num_hosts; do
    inventory=$top/ansible/inventory/hosts-$h
    for f in $num_vars; do
        for l in $var_len; do
            populate_role_defaults $h $f $l
            for i in $(seq 1 $attempts); do
                file=$output_dir/benchmark-role-defaults-hosts-$h-vars-$f-len-$l-attempt-$i.log
                echo "Attempt [$i] -> $file"
                (time ansible-playbook -i $inventory $(basename $playbook)) &> $file
                task_duration=$(awk '$1 == "benchmark-role-defaults" { print $6 }' $file)
                task_duration=${task_duration%?}
                playbook_duration=$(awk '$1 == "real" { print $2 }' $file)
                echo "$h,$f,$l,$i,$task_duration,$playbook_duration" >> $csv
            done
        done
    done
done
