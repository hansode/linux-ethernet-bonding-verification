System Configuration Diagram
----------------------------

```
       ~~~
        |
+-------|-------+
| o o o o o o o |
+---|-------|---+
    |       |
    |       |
+---|-------|--------------------------+
|   |       |               (LinuxBox) |
|+--|-------|--+                       |
||  |       |  |                       |
||eth1     eth2|                       |
||  |       |  |                       |
||  +---+---+  |                       |
||      |      |                       |
||    bond0    |                       |
|+------|------+                       |
|       |                              |
|       |                              |
|   +---+---+                          |
|   |       |                          |
|  ~~~      |    +---+                 |
|           |    |br0|                 |
|           |    |   |                 |
|      vlan2000 ---o |                 |
|                | o |                 |
|                | o |        +------+ |
|                | o |        | lo0  | |
|                | o--- tapA--- eth0 | |
|                | o |        |      | |
|                | o |        +------+ |
|                | o--- tapB           |
|                | o |                 |
|                +---+                 |
|                                      |
+--------------------------------------+
```

How MAC addresses of each nics behave?
--------------------------------------

Terminal-A:

```
$ while date; do for i in /sys/class/net/*/address; do echo $(cat ${i}) ${i}; done | egrep -v '(lo|eth0)'  | sort; echo; sleep 1; done | tee -a mac-addr.log
```

Terminal-B:

```
$ while date; do cat /proc/net/bonding/bond0; echo; sleep 1; done | tee -a bond0-status.log
```

Terminal-C:

```
$ sudo ifdown eth1
```

```
$ grep bond0    mac-addr.log
$ grep vlan2000 mac-addr.log
$ grep br0      mac-addr.log
```
