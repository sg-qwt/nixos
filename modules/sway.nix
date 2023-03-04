{ config, pkgs, lib, home-manager, helpers, ... }:
helpers.mkModule config lib
  "sway"
  "swaywm"
{
  programs.sway = {
    enable = true;
    wrapperFeatures.base = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      qt5.qtwayland
      wl-clipboard
      waybar
      wofi
      mako
      grim
      slurp
      kanshi
      xfce.xfce4-terminal
    ];
  };

  systemd.user.services.kanshi = {
    description = "Kanshi output autoconfig ";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.kanshi}/bin/kanshi
      '';
      RestartSec = 5;
      Restart = "always";
    };
  };

  xdg.portal.wlr.enable = true;

  services.getty.autologinUser = "${config.myos.users.mainUser}";

  environment = {
    loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
      fi
    '';

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";

      XDG_CURRENT_DESKTOP = "sway";

      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      _JAVA_AWT_WM_NONREPARENTING = "1";

      # SDL_VIDEODRIVER = "wayland";
    };

  };

  home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
    xdg.configFile."sway/config".text = (import ../config/sway.nix { inherit config; });

    xdg.configFile."waybar/config".source = ../config/waybar/waybar.json;
    xdg.configFile."waybar/style.css".source = ../config/waybar/style.css;

    xdg.configFile."kanshi/config".source = ../config/kanshi;

    home.packages = with pkgs; [
      (writeShellScriptBin "switch-emacs"
        (import ../config/scripts/switch-emacs.nix { }))

      (writeShellScriptBin "switch-terminal"
        (import ../config/scripts/switch-terminal.nix { }))

    ];
  };
}
