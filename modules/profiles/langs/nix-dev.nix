s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "nix-dev" {
  environment = {
    systemPackages = with pkgs; [
      nil
    ];
  };
}
