#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

# functions

## common

function gen_ifcfg_path() {
  local ifname=${1:-eth0}
  local ifcfg_path=/etc/sysconfig/network-scripts/ifcfg

  echo ${ifcfg_path}-${ifname}
}

function install_ifcfg_file() {
  local ifname=${1:-eth0}

  tee $(gen_ifcfg_path ${ifname}) </dev/stdin
}

## driver/bonding

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

function render_ifcfg_bond_master() {
  local ifname=${1:-bond0}

  cat <<-EOS
	DEVICE=${ifname}
	ONBOOT=yes
	BOOTPROTO=none
	BONDING_OPTS="mode=${mode:-1} miimon=${miimon:-100} updelay=${updelay:-500} fail_over_mac=${fail_over_mac:-1}"
	EOS
}

function render_ifcfg_bond_slave() {
  local ifname=${1:-eth0}
  shift; eval local "${@}"

  cat <<-EOS
	DEVICE=${ifname}
	BOOTPROTO=none
	ONBOOT=yes
	MASTER=${master}
	SLAVE=yes
	EOS
}

function install_ifcfg_bond_master() {
  local ifname=${1:-bond0}

  render_ifcfg_bond_master ${ifname} | install_ifcfg_file ${ifname}
}

function install_ifcfg_bond_slave() {
  local ifname=${1:-eth0}
  shift; eval local "${@}"

  render_ifcfg_bond_slave ${ifname} master=${master} | install_ifcfg_file ${ifname}
}

function install_ifcfg_bond_map() {
  local ifname=${1:-bond0}
  shift; eval local "${@}"

  install_bonding_conf      ${ifname}
  install_ifcfg_bond_master ${ifname}
  install_ifcfg_bond_slave  ${slave}  master=${ifname}
}

## net/bridge

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

## net/8021q

function configure_vlan_networking() {
  local line

  local network_conf_path=/etc/sysconfig/network
  while read line; do
    set ${line}
    if ! egrep -q -w "^${line}" ${network_conf_path}; then
      echo ${line} >> ${network_conf_path}
    fi
  done < <(cat <<-EOS
	VLAN=yes
	VLAN_NAME_TYPE=VLAN_PLUS_VID_NO_PAD
	EOS
  )
}

function render_ifcfg_vlan() {
  local ifname=${1:-vlan1000}

  cat <<-EOS
	DEVICE=${ifname}
	BOOTPROTO=none
	ONBOOT=yes
	EOS
}

function install_ifcfg_vlan_map() {
  local ifname=${1:-vlan1000}
  shift; eval local "${@}"

  render_ifcfg_vlan ${ifname} | install_ifcfg_file ${ifname}

  local physdev_ifcfg_path=$(gen_ifcfg_path ${ifname})
  if [[ ! -f ${physdev_ifcfg_path} ]]; then
    : > ${physdev_ifcfg_path}
  fi

  local physdev_entry="PHYSDEV=${physdev}"
  egrep -q -w "^${physdev_entry}" ${physdev_ifcfg_path} || {
    echo ${physdev_entry} >> ${physdev_ifcfg_path}
  }
}

#

mode=1

install_ifcfg_bond_map bond0 slave=eth1
install_ifcfg_bond_map bond0 slave=eth2
install_ifcfg_bond_map bond1 slave=eth3
install_ifcfg_bond_map bond1 slave=eth4
install_ifcfg_bond_map bond2 slave=eth5
install_ifcfg_bond_map bond2 slave=eth6

configure_vlan_networking

install_ifcfg_vlan_map vlan2000 physdev=bond0
install_ifcfg_vlan_map vlan2001 physdev=bond1
install_ifcfg_vlan_map vlan2002 physdev=bond2

install_ifcfg_bridge_map br0 slave=vlan2000
install_ifcfg_bridge_map br1 slave=vlan2001
install_ifcfg_bridge_map br2 slave=vlan2002
