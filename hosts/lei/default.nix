{ inputs, ... }:
[
  inputs.disko.nixosModules.disko
  ./disko.nix
  ./hardware-configuration.nix
  ./configuration.nix
]
