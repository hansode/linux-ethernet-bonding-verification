#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

mode=1
miimon=100
updelay=500

## configure module

cat <<EOS | sudo tee /etc/modprobe.d/bonding.conf
alias bond0 bonding
alias bond1 bonding
alias bond2 bonding
EOS

## bondX

cat <<EOS | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
ONBOOT=yes
BOOTPROTO=none
BONDING_OPTS="mode=${mode} miimon=${miimon} updelay=${updelay} fail_over_mac=1"
EOS

cat <<EOS | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
DEVICE=bond1
ONBOOT=yes
BOOTPROTO=none
BONDING_OPTS="mode=${mode} miimon=${miimon} updelay=${updelay} fail_over_mac=1"
EOS

cat <<EOS | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond2
DEVICE=bond2
ONBOOT=yes
BOOTPROTO=none
BONDING_OPTS="mode=${mode} miimon=${miimon} updelay=${updelay} fail_over_mac=1"
EOS

## bond0: eth1,eth2

cat <<EOS | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
BOOTPROTO=none
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOS

cat <<EOS | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
BOOTPROTO=none
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOS

## bond1: eth3,eth4

cat <<EOS | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth3
DEVICE=eth3
BOOTPROTO=none
ONBOOT=yes
MASTER=bond1
SLAVE=yes
EOS

cat <<EOS | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth4
DEVICE=eth4
BOOTPROTO=none
ONBOOT=yes
MASTER=bond1
SLAVE=yes
EOS

## bond2: eth5,eth6

cat <<EOS | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth5
DEVICE=eth5
BOOTPROTO=none
ONBOOT=yes
MASTER=bond2
SLAVE=yes
EOS

cat <<EOS | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth6
DEVICE=eth6
BOOTPROTO=none
ONBOOT=yes
MASTER=bond2
SLAVE=yes
EOS

##

# sudo /etc/init.d/network restart
