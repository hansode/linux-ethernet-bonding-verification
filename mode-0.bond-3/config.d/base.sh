#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

mode=0

## functions

function install_bonding_conf() {
  local ifname=${1:-bond0}

  local bonding_conf_path=/etc/modprobe.d/bonding.conf
  if [[ ! -f ${bonding_conf_path} ]]; then
    : > ${bonding_conf_path}
  fi

  local bond_entry="alias ${ifname} bonding"
  egrep -q -w "^${bond_entry}" ${bonding_conf_path} || {
    echo ${bond_entry} >> ${bonding_conf_path}
  }
}

function gen_ifcfg_path() {
  local device=${1:-eth0}
  local ifcfg_path=/etc/sysconfig/network-scripts/ifcfg

  echo ${ifcfg_path}-${device}
}

function render_ifcfg_bond_master() {
  local ifname=${1:-bond0}

  cat <<-EOS
	DEVICE=${ifname}
	ONBOOT=yes
	BOOTPROTO=none
	BONDING_OPTS="mode=${mode:-1} miimon=${miimon:-100} updelay=${updelay:-500} fail_over_mac=1"
	EOS
}

function render_ifcfg_bond_slave() {
  local ifname=${1:-bond0}
  shift; eval local "${@}"

  cat <<-EOS
	DEVICE=${slave}
	BOOTPROTO=none
	ONBOOT=yes
	MASTER=${ifname}
	SLAVE=yes
	EOS
}

function install_ifcfg_file() {
  local ifname=${1:-eth0}

  tee $(gen_ifcfg_path ${ifname}) </dev/stdin
}

function install_ifcfg_bond_master() {
  local ifname=${1:-bond0}

  render_ifcfg_bond_master ${ifname} | install_ifcfg_file ${ifname}
}

function install_ifcfg_bond_slave() {
  local ifname=${1:-bond0}
  shift; eval local "${@}"

  render_ifcfg_bond_slave ${ifname} slave=${slave} | install_ifcfg_file ${slave}
}

function install_ifcfg_bond_map() {
  local ifname=${1:-bond0}
  shift; eval local "${@}"

  install_bonding_conf      ${ifname}
  install_ifcfg_bond_master ${ifname}
  install_ifcfg_bond_slave  ${ifname} slave=${slave}
}

function render_ifcfg_bridge() {
  local ifname=${1:-br0}

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=Bridge
	BOOTPROTO=none
	ONBOOT=yes
	EOS
}

function install_ifcfg_bridge_map() {
  local ifname=${1:-br0}
  shift; eval local "${@}"

  render_ifcfg_bridge ${ifname} | install_ifcfg_file ${ifname}

  local slave_ifcfg_path=$(gen_ifcfg_path ${slave})
  if [[ ! -f ${slave_ifcfg_path} ]]; then
    : > ${slave_ifcfg_path}
  fi

  local bridge_entry="BRIDGE=${ifname}"
  egrep -q -w "^${bridge_entry}" ${slave_ifcfg_path} || {
    echo ${bridge_entry} >> ${slave_ifcfg_path}
  }
}

## bond0: eth1,eth2
## bond1: eth3,eth4
## bond2: eth5,eth6

install_ifcfg_bond_map bond0 slave=eth1
install_ifcfg_bond_map bond0 slave=eth2
install_ifcfg_bond_map bond1 slave=eth3
install_ifcfg_bond_map bond1 slave=eth4
install_ifcfg_bond_map bond2 slave=eth5
install_ifcfg_bond_map bond2 slave=eth6

#install_ifcfg_bridge_map br0 slave=bond0
#install_ifcfg_bridge_map br1 slave=bond1
#install_ifcfg_bridge_map br2 slave=bond2

##

# /etc/init.d/network restart
