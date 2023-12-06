s@{ config, pkgs, lib, ... }:
lib.mkProfile s "desktop-apps"
{
  myos.firefox.enable = true;

  myhome = {
    programs.mpv = {
      enable = true;
      package = pkgs.wrapMpv pkgs.mpv-unwrapped { youtubeSupport = true; };
      config = {
        profile = "gpu-hq";
        hwdec = "auto";
        ytdl-raw-options = "cookies-from-browser=firefox";
      };
    };

    home.packages = with pkgs; [
      # browsers
      (chromium.override {
        commandLineArgs = "--gtk-version=4";
      })
      # media
      spotify
      dmlive
      my.libation
    ];
  };
}
