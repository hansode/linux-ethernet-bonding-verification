#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

cat <<EOS | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond0
IPADDR=10.126.5.43
NETMASK=255.255.255.0
EOS

cat <<EOS | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1
IPADDR=10.126.6.43
NETMASK=255.255.255.0
EOS

cat <<EOS | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond2
IPADDR=10.126.7.43
NETMASK=255.255.255.0
EOS

##

sudo /etc/init.d/network restart
