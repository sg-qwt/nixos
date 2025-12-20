{ pkgs, self }:
let
  tfenv = self + "/caveman/tf-infra.env.age";
  id = self + "/resources/keys/age-yubikey-identity-main.txt";
  terraform = (pkgs.terraform.withPlugins (p: [
    p.hashicorp_azurerm
    p.cloudflare_cloudflare
    p.tailscale_tailscale
    p.hashicorp_time
    p.grafana_grafana
    p.hashicorp_random
  ]));
  tf = (pkgs.writeShellScriptBin "tf" ''
    ${terraform}/bin/terraform -chdir=$FLAKE_INFRA_DIR $@
  '');
in
pkgs.mkShell {
  name = "nixos-dev";
  nativeBuildInputs = [
    pkgs.babashka-unwrapped
    pkgs.azure-cli
    pkgs.jq
    tf
    pkgs.rage
    pkgs.age-plugin-yubikey
    #TODO fix tfout with age
    # (pkgs.writeShellScriptBin "update-tfout"
    #   (import ./tfout.nix { inherit tf pkgs; }))
  ];
  shellHook = ''
    set -a

    export FLAKE_HOME=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    export FLAKE_INFRA_DIR="$FLAKE_HOME/infra"
    export FLAKE_SECRET_DIR="$FLAKE_HOME/caveman"
    source <(rage --decrypt ${tfenv} --identity ${id})

    alias tfp="tf plan"
    alias tfa="tf apply -auto-approve"
    alias tfo="tf output -json | jq 'with_entries(select(.value.sensitive == false)) | map_values(.value) | with_entries(.key |= gsub(\"_\"; \"-\"))' > $FLAKE_HOME/resources/shared-data/tfo.json"



    [ -f $FLAKE_INFRA_DIR/.terraform.lock.hcl ] && rm $FLAKE_INFRA_DIR/.terraform.lock.hcl
    tf init -upgrade 

    set +a
  '';
}
