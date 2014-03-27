#

bonding_mode=1

function gen_priimary() {
  case "${1}" in
    [01]) echo 1 ;; [23]) echo 3 ;; [45]) echo 5 ;;
  esac
}

for i in {0..5}; do
  ifindex=$((${i} + 1))
  configure_ifcfg_bond_map bond$((${i} / 2)) slave=eth${ifindex} mode=${bonding_mode} \
   primary=eth$(gen_priimary ${i}) miimon=100 updelay=10000
done

configure_vlan_conf

for i in {0..2}; do
  vlan_if=vlan200${i}
  configure_ifcfg_vlan_map ${vlan_if} physdev=bond${i}

  br_master_if=br${i}; br_slave_if=${vlan_if}
  map_ifcfg_bridge ${br_master_if} slave=${br_slave_if}
  :
done
