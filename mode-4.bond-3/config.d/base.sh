#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

mode=4

## functions

function install_bonding_conf() {
  local master_if=${1:-bond0}

  local bonding_conf_path=/etc/modprobe.d/bonding.conf
  if [[ ! -f ${bonding_conf_path} ]]; then
    : > ${bonding_conf_path}
  fi

  local bond_entry="alias ${master_if} bonding"
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
  local master_if=${1:-bond0}

  cat <<-EOS
	DEVICE=${master_if}
	ONBOOT=yes
	BOOTPROTO=none
	BONDING_OPTS="mode=${mode:-1} miimon=${miimon:-100} updelay=${updelay:-500}"
	EOS
}

function render_ifcfg_bond_slave() {
  local master_if=${1:-bond0} slave_if=${2:-eth0}

  cat <<-EOS
	DEVICE=${slave_if}
	BOOTPROTO=none
	ONBOOT=yes
	MASTER=${master_if}
	SLAVE=yes
	EOS
}

function install_ifcfg_file() {
  local device=${1:-eth0}

  tee $(gen_ifcfg_path ${device}) </dev/stdin
}

function install_ifcfg_bond_master() {
  local master_if=${1:-bond0}

  render_ifcfg_bond_master ${master_if} | install_ifcfg_file ${master_if}
}

function install_ifcfg_bond_slave() {
  local master_if=${1:-bond0} slave_if=${2:-eth0}

  render_ifcfg_bond_slave ${master_if} ${slave_if} | install_ifcfg_file ${slave_if}
}

function install_ifcfg_bond_map() {
  local master_if=${1:-bond0}; shift
  local slave_ifs=${@} slave_if

  install_bonding_conf      ${master_if}
  install_ifcfg_bond_master ${master_if}
  for slave_if in ${slave_ifs}; do
    install_ifcfg_bond_slave ${master_if} ${slave_if}
  done
}

## bond0: eth1,eth2
## bond1: eth3,eth4
## bond2: eth5,eth6

install_ifcfg_bond_map bond0 eth1 eth2
install_ifcfg_bond_map bond1 eth3 eth4
install_ifcfg_bond_map bond2 eth5 eth6

##

# /etc/init.d/network restart
