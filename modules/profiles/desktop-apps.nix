s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "desktop-apps"
{
  myos.firefox.enable = true;

  home-manager.users."${config.myos.users.mainUser}" = {

    home.packages = with pkgs; [

      # browsers
      # firefox
      chromium

      # media
      vlc
      (spotify.override { deviceScaleFactor = 2; })
      # irc
      slack

      # discord

      (pkgs.symlinkJoin {
        name = "tdesktop";
        paths = [ pkgs.tdesktop ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/telegram-desktop --set QT_QPA_PLATFORM xcb
        '';
      })

      qbittorrent

    ];
  };
}
