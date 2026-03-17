s@{ config, lib, self, ... }:
lib.mkProfile s "cache" {

  nix.settings.substituters = [
    "https://cache.nixos.org?priority=20"
    "https://nix-community.cachix.org?priority=30"
    "https://cache.numtide.com?priority=40"
  ];

  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
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
