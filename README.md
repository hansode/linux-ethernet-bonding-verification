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

Module Parameters
-----------------

| name             | default | description                                                                                 |
|:-----------------|:--------|:--------------------------------------------------------------------------------------------|
| max_bonds        | 0       | Max number of bonded devices                                                                |
| num_grat_arp     | 0644    | Number of gratuitous ARP packets to send on failover event                                  |
| num_unsol_na     | 0644    | Number of unsolicited IPv6 Neighbor Advertisements packets to send on failover event        |
| miimon           | 0       | Link check interval in milliseconds                                                         |
| updelay          | 0       | Delay before considering link up, in milliseconds                                           |
| downdelay        | 0       | Delay before considering link down, in milliseconds                                         |
| use_carrier      | 0       | Use netif_carrier_ok (vs MII ioctls) in miimon; 0 for off, 1 for on (default)               |
| mode             | 0       | Mode of operation                                                                           |
| primary          | 0       | Primary network device to use                                                               |
| lacp_rate        | 0       | Primary network device to use                                                               |
| ad_select        | 0       | 803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)           |
| xmit_hash_policy | 0       | XOR hashing method: 0 for layer 2 (default), 1 for layer 3+4                                |
| arp_interval     | 0       | arp interval in milliseconds                                                                |
| arp_ip_target    | NULL    | arp targets in n.n.n.n form                                                                 |
| arp_validate     | 0       | validate src/dst of ARP probes: none (default), active, backup or all                       |
| fail_over_mac    | 0       | For active-backup, do not set all slaves to the same MAC.  none (default), active or follow |

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
