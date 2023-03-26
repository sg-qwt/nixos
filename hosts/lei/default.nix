{ inputs, ... }:
[
  inputs.disko.nixosModules.disko
  ./disko.nix
  ./configuration.nix
]
