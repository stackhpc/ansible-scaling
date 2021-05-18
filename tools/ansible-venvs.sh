#!/bin/bash

set -e

for version in 2.7 2.8 2.9 2.10 3; do
    rm -rf venv-$version
    python3 -m venv venv-$version
    source venv-$version/bin/activate
    pip install -U pip
    pip install ansible==${version}.*
    deactivate
done
