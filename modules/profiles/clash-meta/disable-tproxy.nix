{ nft-table, route-table, fwmark }:
''
  set +o errexit
  # delete nftables
  nft delete table inet ${nft-table}

  # delete route tables
  ip rule delete fwmark ${fwmark} table ${route-table}
  ip -4 route delete local default dev lo table ${route-table}
  ip -6 route delete local default dev lo table ${route-table}

  # always success
  true
''
