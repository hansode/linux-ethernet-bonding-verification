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
