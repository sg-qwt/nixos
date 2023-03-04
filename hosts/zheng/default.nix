{ inputs, ... }:
[
  ./hardware-configuration.nix
  ./configuration.nix
] ++ inputs.jovian-nixos.nixosModules.jovian.imports
