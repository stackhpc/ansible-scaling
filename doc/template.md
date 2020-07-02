# Template

Playbook: [benchmark-template.yml](ansible/benchmark-template.yml)

Inventory: [hosts-100](ansible/inventory/hosts-100)

The script [benchmark-template.sh](benchmark-template.sh) executes each
benchmark 3 times.

## Template single

This benchmark templates a single file.

Results:

```
benchmark-template-single-1.log:real	0m41.033s
benchmark-template-single-2.log:real	0m41.011s
benchmark-template-single-3.log:real	0m40.891s
```

## Template loop

This benchmark templates multiple (20 per host) files in a loop.

Results:

```
benchmark-template-loop-1.log:real	2m22.160s
benchmark-template-loop-2.log:real	2m20.350s
benchmark-template-loop-3.log:real	2m20.527s
```

## Template jinja include

This benchmark templates a single file using multiple Jinja (20 per host)
includes in a loop.

Results:

```
benchmark-template-jinja-include-1.log:real	0m40.674s
benchmark-template-jinja-include-2.log:real	0m41.748s
benchmark-template-jinja-include-3.log:real	0m40.847s
```

## Template large

This benchmark templates a large file by writing some content multiple times
(1000 per host) in a loop.

Results:

```
benchmark-template-large-1.log:real	0m41.533s
benchmark-template-large-2.log:real	0m41.053s
benchmark-template-large-3.log:real	0m41.576s
```

## Conclusions

The template size, and use of jinja includes, does not appear to have much of
an effect on the execution time. Generating multiple templates in a loop has a
large effect.

The particular behaviour being investigated here was generating multiple
configuration files for a `.d` directory, compared with a single file
containing all configuration. Clearly the single file has a performance
benefit.
