#

bonding_mode=1

function gen_priimary() {
  case "${1}" in
    [01]) echo 1 ;; [23]) echo 3 ;; [45]) echo 5 ;;
  esac
}

for i in {0..5}; do
  ifindex=$((${i} + 1))
  map_ifcfg_bond bond$((${i} / 2)) slave=eth${ifindex} mode=${bonding_mode} \
   primary=eth$(gen_priimary ${i}) miimon=100 updelay=10000
done

configure_vlan_conf

for i in {0..2}; do
  vlan_if=vlan200${i}
  map_ifcfg_vlan ${vlan_if} physdev=bond${i}

  br_master_if=br${i}; br_slave_if=${vlan_if}
  map_ifcfg_bridge ${br_master_if} slave=${br_slave_if}
  :
done
