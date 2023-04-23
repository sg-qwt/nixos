{ inputs, jovian, ... }:
[
  ./hardware-configuration.nix
  ./configuration.nix
  "${jovian}/modules"
]
