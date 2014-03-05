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
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  local bond_opts="mode=${mode:-1}"
  local __param
  for __param in miimon updelay fail_over_mac primary xmit_hash_policy; do
    eval "
      [[ -z "\$${__param}" ]] || bond_opts=\"\${bond_opts} \${__param}=\$${__param}\"
    "
  done

  cat <<-EOS
	DEVICE=${ifname}
	ONBOOT=yes
	BOOTPROTO=none
	BONDING_OPTS="${bond_opts}"
	EOS
}

function render_ifcfg_bond_slave() {
  local ifname=${1:-eth0}
  shift; [[ ${#} == 0 ]] || eval local "${@}"

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
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_bond_master ${ifname} mode=${mode} | install_ifcfg_file ${ifname}
}

function install_ifcfg_bond_slave() {
  local ifname=${1:-eth0}
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_bond_slave ${ifname} master=${master} | install_ifcfg_file ${ifname}
}

function install_ifcfg_bond_map() {
  local ifname=${1:-bond0}
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  install_bonding_conf      ${ifname}
  install_ifcfg_bond_master ${ifname} mode=${mode}
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
  shift; [[ ${#} == 0 ]] || eval local "${@}"

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
  shift; [[ ${#} == 0 ]] || eval local "${@}"

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

bonding_mode=4

for i in {0..5}; do
  ifindex=$((${i} + 1))
  install_ifcfg_bond_map bond$((${i} / 2)) slave=eth${ifindex} mode=${bonding_mode}
done

#configure_vlan_networking

for i in {0..2}; do
 #vlan_if=vlan200${i}
 #install_ifcfg_vlan_map ${vlan_if} physdev=bond${i}

  br_master_if=br${i}; br_slave_if=bond${i}
  install_ifcfg_bridge_map ${br_master_if} slave=${br_slave_if}
  :
done
