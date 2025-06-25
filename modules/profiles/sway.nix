s@{ config, pkgs, lib, self, ... }:
let
  modifier = "Mod4";
  systemctl = lib.getExe' config.systemd.package "systemctl";
  myhomecfg = config.home-manager.users."${config.myos.user.mainUser}";
  swaymsg = lib.getExe' myhomecfg.wayland.windowManager.sway.package "swaymsg";
  status = lib.getExe myhomecfg.programs.i3status-rust.package;
  swayr = lib.getExe myhomecfg.programs.swayr.package;
  pavucontrol = lib.getExe pkgs.pavucontrol;
  grim = lib.getExe pkgs.grim;
  slurp = lib.getExe pkgs.slurp;
  status-config = "${myhomecfg.xdg.configHome}/i3status-rust/config-default.toml";
  wallpaper = self + "/resources/wallpapers/wr.jpg";
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  bento = lib.getExe' self.packages.${pkgs.system}.bbscripts "bento";
  curl = lib.getExe pkgs.curl;
  jq = lib.getExe pkgs.jq;
  swaylock = lib.getExe myhomecfg.programs.swaylock.package;
  loginctl = lib.getExe' pkgs.systemd "loginctl";
  wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
  fcitx5 = lib.getExe config.i18n.inputMethod.package;
  blueman-applet = lib.getExe' pkgs.blueman "blueman-applet";

  monitor = {
    main =
      {
        "lei" =
          {
            id = "Dell Inc. DELL U2718QM MYPFK89J15HL";
            resolution = "3840x2160";
            scale = 2.0;
          };
        "li" =
          {
            id = "Thermotrex Corporation TL140ADXP02-0 Unknown";
            resolution = "2560x1600@165Hz";
            scale = 1.6;
          };
      }."${config.networking.hostName}";
    internal = {
      id = "California Institute of Technology 0x1303 Unknown";
      resolution = "2160x1350";
      scale = 1.5;
    };
    headless = {
      id = "HEADLESS-1";
      resolution = "2800x1752@60Hz";
      scale = 2.0;
    };
  };

  createSwayOutput = monitor: name:
    let
      m = monitor."${name}";
    in
    {
      "${m.id}" = {
        resolution = m.resolution;
        scale = lib.strings.floatToString m.scale;
      };
    };

  queryCoin = symbol: {
    block = "custom";
    command = "${curl} --silent https://api.coinbase.com/v2/prices/${symbol}-USD/spot | ${jq} -r .data.amount";
    hide_when_empty = true;
    interval = 300;
    format = " ${symbol} $text ";
  };
in
lib.mkProfile s "sway"
{
  myos.desktop.enable = true;
  myos.fcitx.enable = true;
  services.blueman.enable = true;

  services.dbus.implementation = "broker";
  programs.dconf.enable = true;
  myos.alacritty.enable = true;
  myos.wayland.enable = true;

  xdg.autostart.enable = lib.mkForce false;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "gtk" ];
      sway.default = [ "wlr" "gtk" ];
    };
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --asterisks --time --cmd 'systemd-cat --identifier=sway sway'";
        user = config.myos.user.mainUser;
      };
    };
  };


  vaultix.secrets.sunshine-pass = { };
  vaultix.secrets.sunshine-salt = { };

  vaultix.templates.sunshine-cred = {
    content = builtins.toJSON {
      username = config.myos.user.mainUser;
      password = config.vaultix.placeholder.sunshine-pass;
      salt = config.vaultix.placeholder.sunshine-salt;
    };
    owner = config.myos.user.mainUser;
  };

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
    settings = {
      # TODO wait https://github.com/LizardByte/Sunshine/pull/2885
      # output_name = monitor.headless;
      output_name = 2;
      credentials_file = config.vaultix.templates.sunshine-cred.path;
      stream_audio = "disabled";
    };
    applications = {
      apps = [
        {
          name = "tablet monitor";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${swaymsg} output HEADLESS-1 enable";
              undo = "${swaymsg} output HEADLESS-1 disable";
            }
          ];
        }
      ];
    };
  };

  myhome = { config, lib, osConfig, ... }:
    {
      home.pointerCursor = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
        gtk.enable = true;
      };

      gtk = {
        enable = true;
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
      };

      services.mako = {
        enable = true;
        settings = {
          default-timeout = 5000;
          ignore-timeout = true;
          max-history = 500;
        };
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
            (queryCoin "BTC")
            (queryCoin "SOL")
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
              format = " {$ssid $signal_strength|Wired} $speed_down.eng(prefix:K) $speed_up.eng(prefix:K) ";
              interval = 5;
            }
            {
              block = "time";
              interval = 5;
              format = " $timestamp.datetime(f:'%a %b %e %R') ";
            }
          ] ++ (lib.optionals
            ((osConfig.networking.hostName == "lei") || (osConfig.networking.hostName == "li")) [
            {
              block = "battery";
              format = " $icon $percentage ";
              full_format = " $icon $percentage ";
              empty_format = " $icon $percentage ";
              device = "BAT0";
            }
          ]);
        };
      };

      programs.wofi = {
        enable = true;
        settings = {
          show = "drun,run";
          allow_images = false;
          insensitive = true;
          key_left = "Ctrl-h";
          key_down = "Down,Ctrl-j";
          key_up = "Up,Ctrl-k";
          key_right = "Ctrl-l";
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
        extraOptions = [ "--unsupported-gpu" ];

        systemd = {
          enable = true;
          xdgAutostart = false;
          variables = [ "--all" ];
        };

        wrapperFeatures = {
          base = true;
          gtk = true;
        };

        config = {
          inherit modifier;

          workspaceAutoBackAndForth = true;


          terminal = lib.getExe config.programs.alacritty.package;

          startup = [
            { command = "emacs"; }
            { command = "\"${swaymsg} create_output; ${swaymsg} output ${monitor.headless.id} disable\""; }
          ] ++ (lib.optional config.services.kanshi.enable
            # workaround for https://github.com/emersion/kanshi/issues/43
            { command = "${systemctl} --user restart kanshi.service"; always = true; }
          ) ++ (lib.optional osConfig.services.blueman.enable
            { command = "${blueman-applet}"; always = true; }
          ) ++ (lib.optional osConfig.i18n.inputMethod.enable
            { command = "${fcitx5} -d --replace"; always = true; }
          );

          menu = "${lib.getExe config.programs.wofi.package}";

          bars = [
            {
              position = "bottom";
              statusCommand = "${status} ${status-config}";
              extraConfig = ''
                icon_theme ${config.gtk.iconTheme.name}
              '';
            }
          ];

          keybindings = lib.mkOptionDefault {
            "${modifier}+e" = "exec ${swayr} switch-to-app-or-urgent-or-lru-window --skip-lru-if-current-doesnt-match emacs || emacs";
            "${modifier}+Shift+Return" = "exec ${swayr} switch-to-app-or-urgent-or-lru-window --skip-lru-if-current-doesnt-match Alacritty || alacritty";
            "${modifier}+s" = "layout toggle split";
            "${modifier}+Tab" = "exec ${swayr} switch-window";
            "Print" = ''
              exec ${grim} \
                -g \"$(${slurp})\" \
                - | ${wl-copy}
            '';
            "${modifier}+Print" = "exec ${grim} ${config.xdg.userDirs.pictures}/screenshot-$(date +\"%Y-%m-%d-%H-%M-%S\").png";
            "XF86AudioRaiseVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86MonBrightnessUp" = "exec ${bento} brightness up";
            "XF86MonBrightnessDown" = "exec ${bento} brightness down";
            "${modifier}+Shift+p" = "exec ${bento} power-menu";
          };

          output = {
            "*" = {
              bg = "${wallpaper} fill";
            };
          } // (createSwayOutput monitor "main")
          // (createSwayOutput monitor "internal")
          // (createSwayOutput monitor "headless");

          workspaceOutputAssign = [
            { workspace = "1"; output = monitor.main.id; }
            { workspace = "2"; output = monitor.main.id; }
            { workspace = "3"; output = monitor.main.id; }
            { workspace = "4"; output = monitor.main.id; }
            { workspace = "5"; output = monitor.main.id; }
            { workspace = "6"; output = monitor.internal.id; }
            { workspace = "7"; output = monitor.internal.id; }
            { workspace = "8"; output = monitor.internal.id; }
            { workspace = "9"; output = monitor.headless.id; }
          ];

          input = {
            "type:keyboard" = {
              xkb_layout = "us";
              xkb_options = "ctrl:nocaps";
            };
            "type:touchpad" = {
              natural_scroll = "enabled";
              tap = "enabled";
              drag_lock = "disabled";
            };
            "4152:6166:SteelSeries_SteelSeries_Rival_106_Gaming_Mouse" = {
              accel_profile = "flat";
            };
          };
          assigns = {
            "8" = [
              { app_id = ""; title = "^Spotify"; }
            ];
          };
          floating.criteria = [
            { app_id = "pavucontrol"; }
            { app_id = "blueman-manager"; }
          ];
          window = {
            titlebar = false;
            commands = [
              {
                criteria = { shell = "xwayland"; };
                command = "title_format \"[XWayland] %title\"";
              }
              {
                criteria = { app_id = "^brave-(?!browser).*"; };
                command = "layout tabbed";
              }
            ];
          };
        };

        extraConfig =
          lib.strings.concatLines [
            "bindswitch --reload --locked lid:on output \"'${monitor.internal.id}'\" disable"
            "bindswitch --reload --locked lid:off output \"'${monitor.internal.id}'\" enable"
          ];
      };

      programs.swaylock = {
        enable = true;
        settings = {
          show-failed-attempts = true;
          ignore-empty-password = true;
          daemonize = true;
          image = "${wallpaper}";
          scaling = "fill";
        };
      };

      services = {
        swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 3600;
              command = "${systemctl} suspend";
            }
          ];
          events = [
            {
              event = "lock";
              command = swaylock;
            }
            {
              event = "before-sleep";
              command = "${loginctl} lock-session";
            }
          ];
        };
      };

      services.kanshi = {
        enable = true;
        settings = [
          {
            profile.name = "undocked";
            profile.outputs = [
              {
                criteria = "${monitor.internal.id}";
                position = "0,0";
                scale = monitor.internal.scale;
              }
              {
                criteria = "${monitor.headless.id}";
                status = "disable";
              }
            ];
          }
          {
            profile.name = "docked";
            profile.outputs = [
              {
                criteria = monitor.main.id;
                position = "0,0";
                scale = monitor.main.scale;
              }
              {
                criteria = monitor.internal.id;
                position = "1920,0";
                scale = monitor.internal.scale;
              }
              {
                criteria = monitor.headless.id;
                status = "disable";
              }
            ];
          }
        ];
      };

      home.packages = with pkgs; [
        wl-clipboard
        xdg-utils
        wf-recorder
        open-in-mpv
      ];

      xdg.configFile."mimeapps.list".force = true;
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          # nix shell nixpkgs#glib -c gio mime x-scheme-handler/mpv
          "x-scheme-handler/mpv" = "open-in-mpv.desktop";
          "application/pdf" = "brave.desktop";
          "text/html" = "brave.desktop";
          "x-scheme-handler/http" = "brave.desktop";
          "x-scheme-handler/https" = "brave.desktop";
          "x-scheme-handler/about" = "brave.desktop";
          "x-scheme-handler/unknown" = "brave.desktop";
        };
      };
    };
}
