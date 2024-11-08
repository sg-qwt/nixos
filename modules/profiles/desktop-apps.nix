s@{ pkgs, lib, ... }:
lib.mkProfile s "desktop-apps"
{
  # file manager
  services.gvfs.enable = true;
  programs.thunar.enable = true;

  myhome = { config, ... }:
    let
      brave-pkg = (pkgs.brave.override { commandLineArgs = "--enable-wayland-ime --wayland-text-input-version=3"; });
      browser = lib.getExe config.programs.chromium.package;
      make-webapp = name: app: (pkgs.makeDesktopItem {
        inherit name;
        desktopName =
          (lib.strings.toUpper (builtins.substring 0 1 name)) +
          (builtins.substring 1 (-1) name);
        exec = "${browser} --new-window --app=\"${app}\"";
      });
    in
    {

      programs.chromium = {
        enable = true;
        package = brave-pkg;
        extensions = [
          { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
          { id = "knheggckgoiihginacbkhaalnibhilkk"; } # notion-web-clipper
          { id = "bhhhlbepdkbapadjdnnojkbgioiodbic"; } # solflare-wallet
          { id = "kdbmhfkmnlmbkgbabkdealhhbfhlmmon"; } # steamdb
          { id = "ngonfifpkpeefnhelnfdkficaiihklid"; } # protondb-for-steam
          { id = "gebbhagfogifgggkldgodflihgfeippi"; } # return-youtube-dislike
          {
            id = "lkbebcjgcmobigpeffafkodonchffocl";
            crxPath = pkgs.fetchurl {
              url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass-paywalls-chrome-clean-3.8.0.0.crx";
              sha256 = "B3H2gR0ktSS+Ridp/wzegR5FnerZLkrYRiSWFyGsx9w=";
            };
            version = "3.8.0";
          }
          {
            id = "ibmfbeedhmhhmgmplmndbdoeejcnjpig";
            crxPath = pkgs.fetchurl {
              url = "https://github.com/Baldomo/open-in-mpv/releases/download/v2.1.0/chrome.crx";
              sha256 = "OAKTpLzrrKXLH8kUHu4c1sLgu/SKikEt839vMxL9Gmg=";
            };
            version = "2.0.1";
          }
        ];
      };

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
