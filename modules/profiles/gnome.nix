s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "gnome"
  (
    let
      ibus-enabled = config.myos.ibus.enable;
      wallpaper = self + "/resources/wallpapers/wr.jpg";
    in
    {

      services.xserver = {
        enable = true;
        displayManager.gdm.autoSuspend = false;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        displayManager.job.preStart = "sleep 5";
        displayManager.autoLogin.enable = true;
        displayManager.autoLogin.user = "${config.myos.users.mainUser}";
      };

      environment = {
        systemPackages = with pkgs; [
          libqalculate
          fd
          # my.pop-launcher
          gnome-console
          gnome.nautilus
          gnome.dconf-editor
          gnomeExtensions.openweather
          gnomeExtensions.kimpanel
          gnomeExtensions.vitals
          # (gnomeExtensions.pop-shell.overrideAttrs
          #   (old: {
          #     version = "unstable-dev";
          #     src = fetchFromGitHub {
          #       owner = "pop-os";
          #       repo = "shell";
          #       rev = "4cf9e144abf0c9775d3dabcd6ac35af70a5b96b4";
          #       hash = "sha256-QHjLPyIjC2K2i9TuqEzGFPesl/CkeFo8nsRbNfph3Kk=";
          #     };
          #   }))
        ];
      };

      programs.file-roller.enable = true;

      services.gnome.core-utilities.enable = false;
      services.gnome.gnome-keyring.enable = lib.mkForce false;

      home-manager.users."${config.myos.users.mainUser}" = { config, lib, ... }: {

        dconf.settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = [
              "kimpanel@kde.org"
              "openweather-extension@jenslody.de"
              "Vitals@CoreCoding.com"
              # "pop-shell@system76.com"
              "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
              "user-theme@gnome-shell-extensions.gcampax.github.com"
            ];
          };

          "org/gnome/shell/extensions/user-theme".name = "Arc";

          "org/gtk/settings/file-chooser".show-hidden = true;

          "org/gnome/desktop/sound".event-sounds = false;

          "org/gnome/mutter".workspaces-only-on-primary = false;
          "org/gnome/mutter".experimental-features = [ "scale-monitor-framebuffer" ];

          "org/gnome/shell/keybindings" = {
            switch-to-application-1 = [ ];
            switch-to-application-2 = [ "<Super>e" ];
            switch-to-application-3 = [ "<Shift><Super>Return" ];
            switch-to-application-4 = [ ];
            switch-to-application-5 = [ ];
            switch-to-application-6 = [ ];
            switch-to-application-7 = [ ];
            switch-to-application-8 = [ ];
            switch-to-application-9 = [ ];
          };

          "org/gnome/desktop/wm/keybindings" = {
            close = [ "<Shift><Super>q" ];
            minimize = [ ];
            move-to-workspace-1 = [ "<Shift><Super>1" ];
            move-to-workspace-2 = [ "<Shift><Super>2" ];
            move-to-workspace-3 = [ "<Shift><Super>3" ];
            move-to-workspace-4 = [ "<Shift><Super>4" ];
            move-to-workspace-5 = [ "<Shift><Super>5" ];
            move-to-workspace-6 = [ "<Shift><Super>6" ];
            move-to-workspace-7 = [ "<Shift><Super>7" ];
            move-to-workspace-8 = [ "<Shift><Super>8" ];
            switch-to-workspace-1 = [ "<Super>1" ];
            switch-to-workspace-2 = [ "<Super>2" ];
            switch-to-workspace-3 = [ "<Super>3" ];
            switch-to-workspace-4 = [ "<Super>4" ];
            switch-to-workspace-5 = [ "<Super>5" ];
            switch-to-workspace-6 = [ "<Super>6" ];
            switch-to-workspace-7 = [ "<Super>7" ];
            switch-to-workspace-8 = [ "<Super>8" ];
            toggle-fullscreen = [ "<Super>f" ];
          };

          "org/gnome/desktop/background" = {
            picture-uri = "file://${wallpaper}";
            picture-options = "zoom";
          };


          "org/gnome/desktop/screensaver" = {
            picture-uri = "file://${wallpaper}";
            picture-options = "zoom";
          };

          "org/gnome/desktop/input-sources" = {
            sources = lib.mkIf ibus-enabled
              (map lib.hm.gvariant.mkTuple
                [ [ "xkb" "us" ] [ "ibus" "rime" ] ]);
            xkb-options = [ "ctrl:nocaps" ];
          };

          "org/gnome/desktop/wm/preferences" = {
            button-layout = "menu:minimize,maximize,close";
            workspace-names = [ "☰乾為天" "☱兌為澤" "☲離為火" "☳震為雷" "☴巽為風" "☵坎為水" "☶艮為山" "☷坤為地" ];
          };

          "org/gnome/desktop/privacy" = {
            report-technical-problems = false;
            send-software-usage-stats = false;
          };

          "org/gnome/shell" = {
            favorite-apps = [
              "org.gnome.Nautilus.desktop"
              "emacs.desktop"
              "org.gnome.Console.desktop"
              "firefox.desktop"
              "spotify.desktop"
            ];
          };
        };
      };
    }
  )
