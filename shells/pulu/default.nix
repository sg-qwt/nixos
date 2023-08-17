{ pkgs, self }:
let
  tfenv = self + "/secrets/tf.env";
in
pkgs.mkShell {
  name = "pulumi-dev";
  nativeBuildInputs = [
    pkgs.pulumi-bin
    pkgs.azure-cli
    (pkgs.maven.override { jdk = pkgs.jdk17; })
  ];
  shellHook = ''
    set -a

    export FLAKE_HOME=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    export FLAKE_INFRA_DIR="$FLAKE_HOME/pulumi"
    export FLAKE_SECRET_DIR="$FLAKE_HOME/secrets"
    source <(${pkgs.sops}/bin/sops --decrypt ${tfenv})

    set +a
  '';
}
