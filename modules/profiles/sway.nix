s@{ config, pkgs, lib, home-manager, self, ... }:
lib.mkProfile s "sway"
{
  programs.dconf.enable = true;
  myos.alacritty.enable = true;
  myos.wayland.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.sway.default = [ "wlr" "gtk" ];
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
      swayr = lib.getExe config.programs.swayr.package;
      pavucontrol = lib.getExe pkgs.pavucontrol;
      status-config = "${config.xdg.configHome}/i3status-rust/config-default.toml";
      wallpaper = self + "/resources/wallpapers/wr.jpg";
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
      bento = self.packages.${pkgs.system}.bento;
      bento-bin = "${bento}/bin/bento";
      curl = lib.getExe pkgs.curl;
      jq = lib.getExe pkgs.jq;

      monitor = {
        main = "Dell Inc. DELL U2718QM MYPFK89J15HL";
        side = "ICD Inc GX259F Unknown";
        internal = "eDP-1";
      };
    in
    {
      home.pointerCursor = {
        package = pkgs.gnome.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
        gtk.enable = true;
      };

      gtk = {
        enable = true;
      };

      services.mako = {
        enable = true;
        defaultTimeout = 5000;
        ignoreTimeout = true;
        extraConfig = ''
          max-history=500
        '';
      };

      programs.i3status-rust = {
        enable = true;
        bars.default = {
          icons = "none";
          theme = "plain";
          blocks = [
            {
              block = "custom";
              command = "${curl} --silent https://wttr.in/shanghai?format=+%C+%t";
              hide_when_empty = true;
              interval = 3000;
              format = " $text ";
            }
            {
              block = "custom";
              command = "${curl} --silent https://api.coinbase.com/v2/prices/SOL-USD/spot | ${jq} -r .data.amount";
              hide_when_empty = true;
              interval = 300;
              format = " SOL $text ";
            }
            {
              block = "disk_space";
              path = "/";
              info_type = "available";
              interval = 60;
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "cpu";
              interval = 5;
            }
            {
              block = "memory";
              format = " $icon $mem_total_used_percents.eng(w:2) ";
            }
            {
              block = "sound";
              click = [{
                button = "left";
                cmd = "${pavucontrol}";
              }];
            }
            {
              block = "net";
              format = " WIFI $signal_strength $speed_down.eng(prefix:K) $speed_up.eng(prefix:K) ";
              device = "wlp0s20f3";
              interval = 5;
            }
            {
              block = "battery";
              format = " $icon $percentage ";
              full_format = " $icon $percentage ";
              empty_format = " $icon $percentage ";
              device = "BAT0";
            }
            {
              block = "time";
              interval = 5;
              format = " $timestamp.datetime(f:'%a %b %e %R') ";
            }
          ];
        };
      };

      programs.wofi = {
        enable = true;
        settings = {
          show = "drun,run";
          allow_images = false;
          insensitive = true;
          key_left = "Control_L-h";
          key_down = "Control_L-j";
          key_up = "Control_L-k";
          key_right = "Control_L-l";
        };
      };

      programs.swayr = {
        enable = true;
        settings = {
          menu = {
            executable = lib.getExe config.programs.wofi.package;
            args = [
              "--show=dmenu"
              "--allow-markup"
              "--insensitive"
              "--cache-file=/dev/null"
              "--parse-search"
              "--height=40%"
              "--prompt={prompt}"
            ];
          };
          format = {
            window_format = "<i>{app_name}</i> — {urgency_start}<b>'{title}'</b>{urgency_end} on workspace {workspace_name} <i>{marks}</i>    <span alpha='20000'>({id})</span>";
          };
        };

        systemd.enable = true;
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
          workspaceAutoBackAndForth = true;
          modifier = "Mod4";
          terminal = lib.getExe config.programs.alacritty.package;
          startup = [
            { command = "firefox"; }
          ];
          menu = "${lib.getExe config.programs.wofi.package}";
          bars = [
            {
              position = "bottom";
              statusCommand = "${status} ${status-config}";
            }
          ];

          keybindings = lib.mkOptionDefault {
            "${modifier}+e" = "exec ${swayr} switch-to-app-or-urgent-or-lru-window --skip-lru-if-current-doesnt-match emacs || emacs";
            "${modifier}+Shift+Return" = "exec ${swayr} switch-to-app-or-urgent-or-lru-window --skip-lru-if-current-doesnt-match Alacritty || alacritty";
            "${modifier}+s" = "layout toggle split";
            "${modifier}+Tab" = "exec ${swayr} switch-window";
            "XF86AudioRaiseVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86MonBrightnessUp" = "exec ${bento-bin} brightness up";
            "XF86MonBrightnessDown" = "exec ${bento-bin} brightness down";
          };

          output = {
            "*" = {
              bg = "${wallpaper} fill";
            };
            "${monitor.internal}" = {
              scale = "1.5";
            };
            # docked setup
            "${monitor.main}" = {
              resolution = "3840x2160";
              position = "0 0";
              scale = "2";
            };
            "${monitor.side}" = {
              resolution = "1920x1080";
              position = "1920 0";
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
          bindswitch --reload --locked lid:on output ${monitor.internal} disable
          bindswitch --reload --locked lid:off output ${monitor.internal} enable

          for_window [app_id="pavucontrol"] floating enable
          for_window [shell="xwayland"] title_format "[XWayland] %title"
        '';
      };

      home.packages = with pkgs; [
        wl-clipboard
      ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "brave.desktop";
          "x-scheme-handler/http" = "brave.desktop";
          "x-scheme-handler/https" = "brave.desktop";
          "x-scheme-handler/about" = "brave.desktop";
          "x-scheme-handler/unknown" = "brave.desktop";
          "application/pdf" = "brave.desktop";
        };
      };
    };
}
