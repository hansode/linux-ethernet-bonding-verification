#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

function append_networking_param() {
  local ifname=${1:-eth0}
  shift; eval local ${@}

  cat <<-EOS | tee -a /etc/sysconfig/network-scripts/ifcfg-${ifname}
	IPADDR=${ip}
	NETMASK=${mask}
	EOS
}

node=node01
#node=node02

case "${node}" in
  node01) ip4=43 partner_ip4=44 ;;
  node02) ip4=44 partner_ip4=43 ;;
esac

append_networking_param bond0 ip=10.126.5.${ip4} mask=255.255.255.0
append_networking_param bond1 ip=10.126.6.${ip4} mask=255.255.255.0
append_networking_param bond2 ip=10.126.7.${ip4} mask=255.255.255.0

##

cat /proc/sys/kernel/printk
echo "7 7 7 7" > /proc/sys/kernel/printk
cat /proc/sys/kernel/printk

##

/etc/init.d/network restart

##

case "${node}" in
  node02)
    ping -c 1 -W 3 10.126.5.${partner_ip4}
    ping -c 1 -W 3 10.126.6.${partner_ip4}
    ping -c 1 -W 3 10.126.7.${partner_ip4}
    ;;
esac
