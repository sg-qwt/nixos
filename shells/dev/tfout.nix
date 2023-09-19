# TODO seperate sensitive and nonsensitive tf output
{ tf, pkgs }:
''
  ${tf}/bin/tf apply -refresh-only -auto-approve

  ${tf}/bin/tf output -json | ${pkgs.jq}/bin/jq 'map_values(.value)' > "$FLAKE_SECRET_DIR/tfout.json"

  ${pkgs.sops}/bin/sops --encrypt --in-place "$FLAKE_SECRET_DIR/tfout.json"
''
