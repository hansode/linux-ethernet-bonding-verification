Linux Ethernet Bonding Testing
==============================

System Requirements
-------------------

+ CentOS 6.4


Bonding Modes
-------------

| # | keyword       |
|:--|:--------------|
| 0 | balance-rr    |
| 1 | active-backup |
| 2 | balance-xor   |
| 3 | broadcast     |
| 4 | 802.3ad       |
| 5 | balance-tlb   |
| 6 | balance-alb   |


Show the bonding module information
-----------------------------------

```
$ modinfo bonding
```

Looking at the bonding configuration
------------------------------------

```
$ watch cat /proc/net/bonding/bond0
$ watch cat /sys/class/net/{bond,br}0/address
$ sudo tail -F /var/log/messages
```

Failover Tests
--------------

### mode=1 active-backup

change the active slave interface:

```
$ sudo ifenslave -c bond0 eth2
$ sudo ifenslave -c bond0 eth1
```

test the failover by detaching (-d) a "dead" interface:

```
$ sudo ifenslave -d bond0 eth1
$ sudo ifenslave -d bond0 eth2
```

reconnect the interface:

```
$ sudo ifenslave    bond0 eth1
$ sudo ifenslave    bond0 eth2
```

References
----------

+ Bonding
   + https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/sec-Using_Channel_Bonding.html
   + https://community.oracle.com/thread/2546040
   + http://tech.g.hatena.ne.jp/rx7/20101018/p1
   + http://blog.tinola.com/?e=4
+ Linux v2.6.32
   + https://github.com/torvalds/linux/tree/v2.6.32/net/bridge
   + https://github.com/torvalds/linux/tree/v2.6.32/net/8021q
   + https://github.com/torvalds/linux/tree/v2.6.32/drivers/net/bonding
