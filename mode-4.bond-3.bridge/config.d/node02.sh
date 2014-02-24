#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

function append_networking_param() {
  local device=${1:-eth0}; shift; eval local ${@}

  cat <<-EOS | tee -a /etc/sysconfig/network-scripts/ifcfg-${device}
	IPADDR=${ip}
	NETMASK=${mask}
	EOS
}

ip4=44

append_networking_param br0 ip=10.126.5.${ip4} mask=255.255.255.0
append_networking_param br1 ip=10.126.6.${ip4} mask=255.255.255.0
append_networking_param br2 ip=10.126.7.${ip4} mask=255.255.255.0

##

/etc/init.d/network restart
