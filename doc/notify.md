# Notify

This benchmark is for quite a specific issue in Kolla Ansible. We currenty
notify multiple handlers in a loop to trigger container restarts. However, if
any item in the loop is changed, all handlers are notified, resulting in
unnecessary container restarts.

We currently have two proposals to resolve this.

1. include\_tasks in a loop, and the included task notifies the correct handler
2. notify all handlers in a task loop as before, but skip handlers that do not
   need to restart

Here we are modelling the check and restart tasks as a sleep with a duration of
one second. We are modelling 5 containers, and testing three cases:

1. all containers should restart
2. no containers should restart
3. one container should restart

Playbook: [benchmark-notify.yml](../ansible/benchmark-notify.yml)

Inventory: [hosts-100](../ansible/inventory/hosts-100)

The script [benchmark-notify.sh](../benchmark-notify.sh) executes each
benchmark 3 times.

# Results (10 hosts)

All handlers notified:

```
benchmark-notify-include-all-changed-1-10.log:real	0m23.392s
benchmark-notify-include-all-changed-2-10.log:real	0m21.114s
benchmark-notify-include-all-changed-3-10.log:real	0m21.490s
benchmark-notify-no-include-all-changed-1-10.log:real	0m19.919s
benchmark-notify-no-include-all-changed-2-10.log:real	0m20.347s
benchmark-notify-no-include-all-changed-3-10.log:real	0m20.722s
```

No handlers notified:

```
benchmark-notify-include-no-change-1-10.log:real	0m14.480s
benchmark-notify-include-no-change-2-10.log:real	0m14.346s
benchmark-notify-include-no-change-3-10.log:real	0m16.259s
benchmark-notify-no-include-no-change-1-10.log:real	0m11.344s
benchmark-notify-no-include-no-change-2-10.log:real	0m12.001s
benchmark-notify-no-include-no-change-3-10.log:real	0m11.241s
```

One handler notified:

```
benchmark-notify-include-one-changed-1-10.log:real	0m16.128s
benchmark-notify-include-one-changed-2-10.log:real	0m15.285s
benchmark-notify-include-one-changed-3-10.log:real	0m15.659s
benchmark-notify-no-include-one-changed-1-10.log:real	0m20.902s
benchmark-notify-no-include-one-changed-2-10.log:real	0m23.392s
benchmark-notify-no-include-one-changed-3-10.log:real	0m20.178s
```

# Results (100 hosts)

All handlers notified:

```
benchmark-notify-include-all-changed-1-100.log:real	2m10.839s
benchmark-notify-include-all-changed-2-100.log:real	2m10.677s
benchmark-notify-include-all-changed-3-100.log:real	2m10.295s
benchmark-notify-no-include-all-changed-1-100.log:real	2m2.958s
benchmark-notify-no-include-all-changed-2-100.log:real	2m5.265s
benchmark-notify-no-include-all-changed-3-100.log:real	2m0.528s
```

No handlers notified:

```
benchmark-notify-include-no-change-1-100.log:real	1m28.409s
benchmark-notify-include-no-change-2-100.log:real	1m28.665s
benchmark-notify-include-no-change-3-100.log:real	1m33.858s
benchmark-notify-no-include-no-change-1-100.log:real	1m16.471s
benchmark-notify-no-include-no-change-2-100.log:real	1m16.790s
benchmark-notify-no-include-no-change-3-100.log:real	1m19.012s
```

One handler notified:

```
benchmark-notify-include-one-changed-1-100.log:real	1m35.372s
benchmark-notify-include-one-changed-2-100.log:real	1m36.386s
benchmark-notify-include-one-changed-3-100.log:real	1m37.173s
benchmark-notify-no-include-one-changed-1-100.log:real	2m0.285s
benchmark-notify-no-include-one-changed-2-100.log:real	2m0.414s
benchmark-notify-no-include-one-changed-3-100.log:real	2m2.288s
```

# Results (200 hosts)

All handlers notified:

```
benchmark-notify-include-all-changed-1-200.log:real	4m28.494s
benchmark-notify-include-all-changed-2-200.log:real	4m24.483s
benchmark-notify-include-all-changed-3-200.log:real	4m33.415s
benchmark-notify-no-include-all-changed-1-200.log:real	4m2.870s
benchmark-notify-no-include-all-changed-2-200.log:real	3m59.503s
benchmark-notify-no-include-all-changed-3-200.log:real	3m57.586s
```

No handlers notified:

```
benchmark-notify-include-no-change-1-200.log:real	3m7.613s
benchmark-notify-include-no-change-2-200.log:real	3m7.307s
benchmark-notify-include-no-change-3-200.log:real	3m8.782s
benchmark-notify-no-include-no-change-1-200.log:real	2m43.753s
benchmark-notify-no-include-no-change-2-200.log:real	2m46.839s
benchmark-notify-no-include-no-change-3-200.log:real	2m35.074s
```

One handler notified:

```
benchmark-notify-include-one-changed-1-200.log:real	3m12.717s
benchmark-notify-include-one-changed-2-200.log:real	3m21.716s
benchmark-notify-include-one-changed-3-200.log:real	3m20.945s
benchmark-notify-no-include-one-changed-1-200.log:real	4m1.291s
benchmark-notify-no-include-one-changed-2-200.log:real	3m57.729s
benchmark-notify-no-include-one-changed-3-200.log:real	4m0.707s
```

# Conclusions

When all containers need to restart, the no-include method performs better
every time.

When no containers need to restart, the no-include method performs better every
time.

When one container needs to restart, the include method performs better every
time.

This all makes sense, as there is overhead to the include method, but it can
avoid running handler tasks when they have not changed.
