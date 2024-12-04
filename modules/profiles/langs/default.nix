s@{ config, pkgs, lib, self, ... }:
with lib;
let
  cfg = config.myos.langs;
in
{
  imports = [
    ./clojure-dev.nix
    ./rust-dev.nix
  ];

  options.myos.langs = {
    clojure = mkEnableOption "clojrue dev";
    rust = mkEnableOption "rust dev";
  };

  config = {
    myos.clojure-dev.enable = cfg.clojure;
    myos.rust-dev.enable = cfg.rust;
  };
}
