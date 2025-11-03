s@{ config, lib, self, ... }:
let
  inherit (self.shared-data) fqdn;
in
lib.mkProfile s "cache" {

  vaultix.secrets.attic-hello-token = { };
  vaultix.templates.netrc.content = ''
    machine attic.${fqdn.edg}
    password ${config.vaultix.placeholder.attic-hello-token}
  '';

  nix.settings.netrc-file = config.vaultix.templates.netrc.path;

  nix.settings.substituters = [
    "https://cache.nixos.org?priority=20"
    "https://nix-community.cachix.org?priority=30"
    "https://attic.${fqdn.edg}/hello?priority=40"
  ];

  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "hello:1i/LXgtEDpGmjTelurlADkaoFZdBP55NBJMxL2swzLY="
  ];

  vaultix.secrets.github-pat = { };

  users.groups.nix-access-tokens = { };

  vaultix.templates.nix-extra-config = {
    content = ''
      extra-access-tokens = github.com=${config.vaultix.placeholder.github-pat}
    '';
    mode = "0440";
    group = config.users.groups.nix-access-tokens.name;
  };
  myos.user.extraGroups = [ config.users.groups.nix-access-tokens.name ];

  nix.extraOptions = ''
    !include ${config.vaultix.templates.nix-extra-config.path}
  '';
}
