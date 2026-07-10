{ inputs, ... }:
[
  inputs.jovian.nixosModules.jovian
  ./hardware-configuration.nix
  ./configuration.nix
]
