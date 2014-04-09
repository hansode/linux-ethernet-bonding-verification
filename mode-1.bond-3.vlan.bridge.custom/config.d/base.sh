#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

# Do some changes ...

ifcfg_setup=/usr/local/bin/ifcfg-setup

if [[ ! -f ${ifcfg_setup} ]]; then
  curl -fSkL https://raw.githubusercontent.com/hansode/ifcfg-setup/master/bin/ifcfg-setup -o ${ifcfg_setup}
  chmod +x ${ifcfg_setup}
fi
#

bonding_mode=1

function gen_priimary() {
  case "${1}" in
    [01]) echo 1 ;; [23]) echo 3 ;; [45]) echo 5 ;;
  esac
}

for i in {0..5}; do
  ifindex=$((${i} + 1))
  /usr/local/bin/ifcfg-setup map bond bond$((${i} / 2)) slave=eth${ifindex} mode=${bonding_mode} \
   primary=eth$(gen_priimary ${i}) miimon=100 updelay=10000
done

for i in {0..2}; do
  vlan_if=vlan200${i}
  /usr/local/bin/ifcfg-setup map vlan ${vlan_if} physdev=bond${i}

  br_master_if=br${i}; br_slave_if=${vlan_if}
  /usr/local/bin/ifcfg-setup map bridge ${br_master_if} slave=${br_slave_if}
  :
done
