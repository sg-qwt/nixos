s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "rust-dev" {
  environment = {
    systemPackages = with pkgs; [
      rustc
      cargo

      rustfmt
      rust-analyzer
    ];
  };
}
