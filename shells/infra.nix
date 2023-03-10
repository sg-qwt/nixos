{ pkgs, rootPath }:
let tfenv = rootPath + "/secrets/tf.env"; in
  pkgs.mkShell {
    name = "terraform-infra";
    nativeBuildInputs = [
      pkgs.azure-cli
      (pkgs.terraform.withPlugins (p: [
        p.azurerm
      ]))
    ];
    shellHook = ''
      set -a
      source <(${pkgs.sops}/bin/sops --decrypt ${tfenv})
      set +a
    '';
}
