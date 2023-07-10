s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "desktop-apps"
{
  myos.firefox.enable = true;

  home-manager.users."${config.myos.users.mainUser}" = {

    home.packages = with pkgs; [
      # browsers
      chromium

      # media
      mpv
      spotify
      dmlive
    ];
  };
}
