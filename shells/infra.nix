{ pkgs, rootPath }:
let
  tfenv = rootPath + "/secrets/tf.env";
  terraform = (pkgs.terraform.withPlugins (p: [
    p.azurerm
    p.cloudflare
  ]));
  tf = (pkgs.writeShellScriptBin "tf" ''
    ${terraform}/bin/terraform -chdir=$FLAKE_INFRA_DIR $@
  '');
in
pkgs.mkShell {
  name = "terraform-infra";
  nativeBuildInputs = [
    pkgs.azure-cli
    pkgs.jq
    tf
    (pkgs.writeShellScriptBin "update-tfout"
      (import ./tfout.nix { inherit tf pkgs; }))
  ];
  shellHook = ''
    set -a

    export FLAKE_HOME=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    export FLAKE_INFRA_DIR="$FLAKE_HOME/infra"
    export FLAKE_SECRET_DIR="$FLAKE_HOME/secrets"
    source <(${pkgs.sops}/bin/sops --decrypt ${tfenv})

    alias tfp="tf plan"
    alias tfa="tf apply -auto-approve"

    tf init -upgrade 

    set +a
  '';
}
