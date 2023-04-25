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

      # irc
      slack
      element-desktop
      (pkgs.symlinkJoin {
        name = "tdesktop";
        paths = [ pkgs.tdesktop ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/telegram-desktop --set QT_QPA_PLATFORM xcb
        '';
      })
    ];
  };
}
