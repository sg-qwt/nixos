s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "gaming"
{
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        wqy_microhei
        wqy_zenhei
        liberation_ttf
      ];
    };
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    remotePlay.openFirewall = true;
  };

  # controller
  hardware.xone.enable = true;
}
