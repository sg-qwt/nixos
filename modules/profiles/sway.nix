s@{ config, pkgs, lib, home-manager, self, ... }:
lib.mkProfile s "sway"
{
  programs.dconf.enable = true;
  myos.alacritty.enable = true;
  myos.wayland.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --asterisks --time --cmd sway";
        user = config.myos.user.mainUser;
      };
    };
  };

  myhome = { config, lib, ... }:
    let
      modifier = config.wayland.windowManager.sway.config.modifier;
      status = lib.getExe config.programs.i3status-rust.package;
      status-config = "${config.xdg.configHome}/i3status-rust/config-default.toml";
      wallpaper = self + "/resources/wallpapers/wr.jpg";
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
    in
    {
      gtk = {
        enable = true;
      };

      services.mako = {
        enable = true;
      };

      programs.i3status-rust = {
        enable = true;
      };

      wayland.windowManager.sway = {
        enable = true;
        systemd = {
          enable = true;
          xdgAutostart = true;
        };

        wrapperFeatures = {
          base = true;
          gtk = true;
        };

        config = {
          modifier = "Mod4";
          terminal = lib.getExe config.programs.alacritty.package;
          startup = [
            { command = "firefox"; }
          ];
          gaps = {
            inner = 5;
            outer = 5;
            smartGaps = true;
          };
          menu = "${lib.getExe pkgs.wofi} --show run | ${pkgs.findutils}/bin/xargs swaymsg exec --";
          bars = [
            { statusCommand = "${status} ${status-config}"; }
          ];
          keybindings = lib.mkOptionDefault {
            "XF86AudioRaiseVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.brightnessctl} set 5%+";
            "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.brightnessctl} set 5%-";
          };
          output = {
            "*" = {
              bg = "${wallpaper} fill";
            };
            eDP-1 = {
              scale = "1.5";
            };
          };
          input = {
            "1:1:AT_Translated_Set_2_keyboard" = {
              xkb_options = "ctrl:nocaps";
            };
            "1267:12624:ELAN0670:00_04F3:3150_Touchpad" = {
              natural_scroll = "enabled";
              tap = "enabled";
            };
          };
        };

        extraConfig = ''
          for_window [app_id="pavucontrol"] floating enable
          for_window [shell="xwayland"] title_format "[XWayland] %title"
        '';
      };

      home.packages = with pkgs; [
        pavucontrol
        wl-clipboard
        # (writeShellScriptBin "switch-emacs"
        #   (import (self + "/config/scripts/switch-emacs.nix") { }))

        # (writeShellScriptBin "switch-terminal"
        #   (import (self + "/config/scripts/switch-terminal.nix") { }))

      ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "firefox.desktop";
          "x-scheme-handler/http"  = "firefox.desktop";
          "x-scheme-handler/https"  = "firefox.desktop";
          "x-scheme-handler/about" = "firefox.desktop";
          "x-scheme-handler/unknown" = "firefox.desktop";
          "application/pdf" = "firefox.desktop";
        };
      };
    };
}
