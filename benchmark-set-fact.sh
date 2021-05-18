#!/bin/bash

set -e
set -o pipefail

# Parameters
num_hosts="10 100 200"
num_facts="10 100 1000 10000"
fact_length="1 100 1000"
attempts=3

playbook=$(pwd)/benchmarks/set-fact/benchmark-set-fact.yml
output_dir=$(pwd)/results
csv=$output_dir/benchmark-set-fact.csv

function populate_playbook {
    local f=$1
    local l=$2
    # Create a playbook
    local fact_value=$(head -c $l /dev/zero | tr '\0' '\141')
cat << EOF > $playbook
- name: Benchmark set_fact
  hosts: all
  gather_facts: no
  tasks:
    - name: set some facts
      set_fact:
$(python3 $top/tools/make-vars-yaml.py $f $fact_value | sed -e 's/^/        /g')

    - name: Hello, world
      debug:
        msg: Hello, world
EOF
}

mkdir -p $output_dir
top=$(pwd)
pushd $(dirname $playbook)

echo "Hosts,Facts,Fact length,Attempt,Task duration,Playbook duration" > $csv

for h in $num_hosts; do
    inventory=inventory/hosts-$h
    for f in $num_facts; do
        for l in $fact_length; do
            populate_playbook $f $l
            for i in $(seq 1 $attempts); do
                file=$output_dir/benchmark-set-fact-hosts-$h-facts-$f-length-$l-attempt-$i.log
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
