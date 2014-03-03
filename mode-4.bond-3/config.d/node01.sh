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

ip4=43

append_networking_param bond0 ip=10.126.5.${ip4} mask=255.255.255.0
append_networking_param bond1 ip=10.126.6.${ip4} mask=255.255.255.0
append_networking_param bond2 ip=10.126.7.${ip4} mask=255.255.255.0

##

/etc/init.d/network restart
