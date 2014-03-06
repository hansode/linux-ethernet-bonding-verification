#!/bin/bash
#
# requires:
#  bash
#

# functions

## common

function run_in_target() {
  local node=${1}; shift
  vagrant ssh ${node} -c "${@}"
}

function show_ipaddr() {
  local node=${1}
  shift; eval local "${@}"
  run_in_target ${node} "ip addr show ${ifname} | grep -w inet"
}

## setup

run_in_target node01 "sudo ifup eth1"
run_in_target node01 "sudo ifup eth2"

## check

run_in_target node01 "ip link show bond0"
run_in_target node02 "ip link show bond0"

node01_bond0_01=$(run_in_target node01 "cat /proc/net/bonding/bond0")
node02_bond0_01=$(run_in_target node02 "cat /proc/net/bonding/bond0")

## main

run_in_target node01 "sudo ifdown eth1"

node01_bond0_02=$(run_in_target node01 "cat /proc/net/bonding/bond0")
node02_bond0_02=$(run_in_target node02 "cat /proc/net/bonding/bond0")

## diff

echo ... diff node01
diff <(echo "${node01_bond0_01}") <(echo "${node01_bond0_02}") || :
echo ... diff node02
diff <(echo "${node02_bond0_01}") <(echo "${node02_bond0_02}") || :
