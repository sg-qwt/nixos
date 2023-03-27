{ inputs, ... }:
[
  ./hardware-configuration.nix
  ./configuration.nix
  "${inputs.jovian}/modules"
]
