s@{ pkgs, lib, ... }:
lib.mkProfile s "desktop-apps"
{
  # file manager
  services.gvfs.enable = true;
  programs.thunar.enable = true;

  programs.chromium = {
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
      "knheggckgoiihginacbkhaalnibhilkk" # notion-web-clipper
      "bhhhlbepdkbapadjdnnojkbgioiodbic" # solflare-wallet
      "kdbmhfkmnlmbkgbabkdealhhbfhlmmon" # steamdb
      "ngonfifpkpeefnhelnfdkficaiihklid" # protondb-for-steam
      "gebbhagfogifgggkldgodflihgfeippi" # return-youtube-dislike
    ];
  };

  myhome = { config, ... }:
    let
      brave-pkg = (pkgs.brave.override {
        commandLineArgs = [
          "--enable-wayland-ime"
          "--wayland-text-input-version=3"
          "--enable-features=WaylandLinuxDrmSyncobj"
          "--password-store=basic"
        ];
      });
      browser = lib.getExe brave-pkg;
      make-webapp = name: app: (pkgs.makeDesktopItem {
        inherit name;
        desktopName =
          (lib.strings.toUpper (builtins.substring 0 1 name)) +
          (builtins.substring 1 (-1) name);
        exec = "${browser} --new-window --app=\"${app}\"";
      });
    in
    {
      programs.mpv = {
        enable = true;
        config = {
          profile = "gpu-hq";
          hwdec = "auto";
          ytdl-raw-options = "cookies-from-browser=firefox";
          input-ipc-server = "/tmp/mpvsocket";
        };
      };

      home.packages = with pkgs; [
        brave-pkg
        firefox

        # media
        spotify
        dmlive
        libation

        # chat
        (make-webapp "element" "https://app.element.io")
        (make-webapp "slack" "https://app.slack.com/client")
        (make-webapp "discord" "https://discord.com/app")
        (make-webapp "telegram" "https://web.telegram.org")
      ];
    };
}
