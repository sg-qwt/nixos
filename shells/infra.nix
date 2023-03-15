{ pkgs, rootPath }:
let
  tfenv = rootPath + "/secrets/tf.env";
  terraform = (pkgs.terraform.withPlugins (p: [p.azurerm]));
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
      (import ./tfout.nix {inherit tf pkgs;}))
  ];
  shellHook = ''
    if ! [ -d "$PWD/infra" ]; then
      echo "Wrong directory"
      exit 1
    fi

    set -a

    export FLAKE_INFRA_DIR="$PWD/infra"
    export FLAKE_SECRET_DIR="$PWD/secrets"

    source <(${pkgs.sops}/bin/sops --decrypt ${tfenv})

    set +a
  '';
}
