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

for i in {0..5}; do
  ifindex=$((${i} + 1))
  map_ifcfg_bond bond$((${i} / 2)) slave=eth${ifindex} mode=${bonding_mode}
done

for i in {0..2}; do
 #vlan_if=vlan200${i}
 #map_ifcfg_vlan ${vlan_if} physdev=bond${i}

  br_master_if=br${i}; br_slave_if=bond${i}
  map_ifcfg_bridge ${br_master_if} slave=${br_slave_if}
  :
done
