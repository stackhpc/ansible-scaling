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

## Template lookup plugin

This benchmark templates a single file using multiple (20 per host) invocations
of the Ansible `template` lookup plugin. This can be used to overcome a
limitation of Jinja includes in Ansible where they are limited to the same
directory or a subdirectory of the template.

Results:

```
benchmark-template-lookup-1.log:real	1m5.994s
benchmark-template-lookup-2.log:real	1m5.056s
benchmark-template-lookup-3.log:real	1m3.456s
```

## Template lookup plugin or Jinja include

This benchmark templates a single file using multiple includes (20 per host) in
a loop. Odd numbers use the `template` lookup plugin, the rest use a Jinja
include.

Results:

```
benchmark-template-lookup-or-jinja-include-1.log:real	0m52.305s
benchmark-template-lookup-or-jinja-include-2.log:real	0m51.738s
benchmark-template-lookup-or-jinja-include-3.log:real	0m57.746s
```

## Conclusions

The template size, and use of jinja includes, does not appear to have much of
an effect on the execution time. Generating multiple templates in a loop has a
large effect.

The particular behaviour being investigated here was generating multiple
configuration files for a `.d` directory, compared with a single file
containing all configuration. Clearly the single file has a performance
benefit. Jinja includes allow the continued use of separate files locally, and
where included templates live in a different directory the lookup plugin can be
used with a small overhead.
