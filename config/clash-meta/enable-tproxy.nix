{ fwmark, ports, nft-table, route-table }:
let
  nftscript = (import ./tproxy.nft { inherit fwmark ports nft-table; });
in
''

ip rule add fwmark ${fwmark} table ${route-table}
ip -4 route add local default dev lo table ${route-table}
ip -6 route add local default dev lo table ${route-table}

nft --file - <<EOF
${nftscript}
EOF

''
