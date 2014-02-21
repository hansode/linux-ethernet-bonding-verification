#!/bin/bash
#
# requires:
#  bash
#
set -e
#set -x

function show_bonding_status() {
  [[ -d /proc/net/bonding ]] || return 0
  for i in /proc/net/bonding/*; do
    echo === ${i} ===
    cat ${i}
  done
}

function list_bonding_if() {
  [[ -f /sys/class/net/bonding_masters ]] || return 0
  cat /sys/class/net/bonding_masters
}

function show_nic_mac() {
  for i in /sys/class/net/*; do
    [[ -d ${i} ]] || continue
    echo $(basename ${i}) $(cat ${i}/address)
  done
}

#list_bonding_if
#show_bonding_status
show_nic_mac

for i in /sys/class/net/*/bonding/slaves; do
  echo ${i} $(cat ${i})
done

for i in /sys/class/net/*/bonding/mode; do
  echo ${i} $(cat ${i})
done

for i in /sys/class/net/*/bonding/updelay; do
  echo ${i} $(cat ${i})
done

for i in /sys/class/net/*/bonding/miimon; do
  echo ${i} $(cat ${i})
done

for i in /sys/class/net/*/bonding/mii_status; do
  echo ${i} $(cat ${i})
done

for i in $(list_bonding_if); do
  sudo mii-tool -v ${i}
done
