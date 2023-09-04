s@{ config, pkgs, lib, self, ... }:
with lib;
let
  cfg = config.myos.langs;
in
{
  imports = [
    ./clojure-dev.nix
    ./rust-dev.nix
    ./nix-dev.nix
  ];

  options.myos.langs = {
    clojure = mkEnableOption "clojrue dev";
    rust = mkEnableOption "rust dev";
    nix = mkEnableOption "nix dev";
  };

  config = {
    myos.clojure-dev.enable = cfg.clojure;
    myos.rust-dev.enable = cfg.rust;
    myos.nix-dev.enable = cfg.nix;
  };
}
