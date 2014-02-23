Linux Ethernet Bonding Testing
==============================

System Requirements
-------------------

+ CentOS 6.4


Bonding Policy
--------------

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
$ sudo tail -F /var/log/messages
```

Failover Tests
--------------

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

Links
-----

+ [Using Channel Bonding](https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/sec-Using_Channel_Bonding.html)
+ [GUIDE: Oracle VM VirtualBox and Oracle Linux NIC bonding](https://community.oracle.com/thread/2546040)
