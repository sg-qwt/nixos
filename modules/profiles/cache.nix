s@{ config, pkgs, lib, inputs, self, ... }:
let
  inherit (config.myos.data) fqdn ports;
in
lib.mkProfile s "cache" {
  sops.secrets.attic-hello-token = {
    sopsFile = self + "/secrets/secrets.yaml";
  };

  sops.templates.netrc.content = ''
    machine attic.${fqdn.edg}
    password ${config.sops.placeholder.attic-hello-token}
  '';

  nix.settings.netrc-file = config.sops.templates.netrc.path;

  nix.settings.substituters = [
    "https://cache.nixos.org?priority=20"
    "https://nix-community.cachix.org?priority=30"
    "https://attic.${fqdn.edg}/hello?priority=40"
  ];

  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "hello:1i/LXgtEDpGmjTelurlADkaoFZdBP55NBJMxL2swzLY="
  ];
}
