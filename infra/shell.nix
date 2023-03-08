{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = [
      pkgs.azure-cli
      (pkgs.terraform.withPlugins (p: [
        p.azurerm
      ]))
    ];
    shellHook = ''
      set -a
      source <(${pkgs.sops}/bin/sops --decrypt ${toString ../secrets/tf.env})
      set +a
    '';
}
