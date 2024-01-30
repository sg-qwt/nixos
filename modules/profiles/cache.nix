s@{ config, lib, self, ... }:
let
  inherit (config.myos.data) fqdn;
in
lib.mkProfile s "cache" {
  sops.secrets.attic-hello-token = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "nix-daemon.service" ];
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

  sops.secrets.github-pat = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "nix-daemon.service" ];
  };

  users.groups.nix-access-tokens = { };
  sops.templates.nix-extra-config = {
    content = ''
      extra-access-tokens = github.com=${config.sops.placeholder.github-pat}
    '';
    mode = "0440";
    group = config.users.groups.nix-access-tokens.name;
  };
  myos.user.extraGroups = [ config.users.groups.nix-access-tokens.name ];

  nix.extraOptions = ''
    !include ${config.sops.templates.nix-extra-config.path}
  '';
}
