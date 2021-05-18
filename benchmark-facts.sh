#!/bin/bash

set -e

# Parameters
num_hosts="200" #"10 100 200"
num_facts="10000" #"10 100 1000 10000"
fact_len="1000" #"1 100 1000"
attempts=3

playbook=$(pwd)/benchmarks/facts/benchmark-facts.yml
output_dir=$(pwd)/results
csv=$output_dir/benchmark-facts.csv

function populate_fact_cache {
    local h=$1
    local f=$2
    local l=$3
    # Create a set of dummy facts.
    mkdir -p fact-cache
    local fact_value=$(head -c $l /dev/zero | tr '\0' '\141')
    python3 $top/tools/make-facts-json.py $f $fact_value > fact-cache/facts-source

    # Populate fact cache with symlinks to dummy facts.
    for i in $(seq 1 $h); do
        host_facts=fact-cache/h$(printf %03d $i)
        if [[ -L $host_facts ]]; then
            unlink $host_facts
        fi
        ln -s facts-source $host_facts
    done
}

mkdir -p $output_dir
top=$(pwd)
pushd $(dirname $playbook)

echo "Hosts,Facts,Fact length,Attempt,Task duration,Playbook duration" > $csv

for h in $num_hosts; do
    inventory=$top/ansible/inventory/hosts-$h
    for f in $num_facts; do
        for l in $fact_len; do
            populate_fact_cache $h $f $l
            for i in $(seq 1 $attempts); do
                file=$output_dir/benchmark-facts-no-inject-hosts-$h-facts-$f-len-$l-attempt-$i.log
                echo "Attempt [$i] -> $file"
                export ANSIBLE_INJECT_FACT_VARS=False
                (time ansible-playbook -i $inventory $(basename $playbook)) &> $file
                task_duration=$(awk '$1 == "Hello," { print $4 }' $file)
                task_duration=${task_duration%?}
                playbook_duration=$(awk '$1 == "real" { print $2 }' $file)
                echo "$h,$f,$l,$i,$task_duration,$playbook_duration" >> $csv
            done
        done
    done
done
