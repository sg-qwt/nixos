s@{ config, pkgs, lib, helpers, inputs, self, ... }:
let
  inherit (config.myos.data) fqdn ports;
in
helpers.mkProfile s "cache" {
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
    "https://ooo.${fqdn.edg}/ghcr.io/sg-qwt/nixos?priority=40"
    "https://attic.${fqdn.edg}/hello?priority=50"
  ];

  nix.settings.trusted-public-keys = [
    "oranc:RZWCxVsNWs/6qPkfB17Mmk9HpkTv87UXnldHtGKkWLk="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "hello:1i/LXgtEDpGmjTelurlADkaoFZdBP55NBJMxL2swzLY="
  ];
}
