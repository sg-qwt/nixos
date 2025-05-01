{ pkgs, self }:
let
  tfenv = self + "/secrets/tf-infra.env.age";
  id = self + "/resources/keys/age-yubikey-identity-main.txt";
  terraform = (pkgs.terraform.withPlugins (p: [
    p.azurerm
    p.cloudflare
    p.tailscale
    p.time
    p.grafana
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
    export FLAKE_SECRET_DIR="$FLAKE_HOME/secrets"
    source <(rage --decrypt ${tfenv} --identity ${id})

    alias tfp="tf plan"
    alias tfa="tf apply -auto-approve"


    [ -f $FLAKE_INFRA_DIR/.terraform.lock.hcl ] && rm $FLAKE_INFRA_DIR/.terraform.lock.hcl
    tf init -upgrade 

    set +a
  '';
}
