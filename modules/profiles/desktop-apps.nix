s@{ pkgs, lib, ... }:
lib.mkProfile s "desktop-apps"
{
  myos.firefox.enable = true;

  myhome = { config, ... }:
    let
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
        package = (pkgs.my.brave.override {
          commandLineArgs = "--gtk-version=4";
        });
        extensions = [
          { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
          { id = "knheggckgoiihginacbkhaalnibhilkk"; } # notion-web-clipper
          { id = "bhhhlbepdkbapadjdnnojkbgioiodbic"; } # solflare-wallet
          { id = "ljobjlafonikaiipfkggjbhkghgicgoh"; } # edit-with-emacs
          { id = "kdbmhfkmnlmbkgbabkdealhhbfhlmmon"; } # steamdb
          { id = "ngonfifpkpeefnhelnfdkficaiihklid"; } # protondb-for-steam
          {
            id = "dcpihecpambacapedldabdbpakmachpb";
            updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml";
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
        package = pkgs.wrapMpv pkgs.mpv-unwrapped { youtubeSupport = true; };
        config = {
          profile = "gpu-hq";
          hwdec = "auto";
          ytdl-raw-options = "cookies-from-browser=firefox";
          input-ipc-server = "/tmp/mpvsocket";
        };
      };

      home.packages = with pkgs; [
        # media
        spotify
        (dmlive.overrideAttrs (oldAttrs: rec {
          version = "5.3.2";
          src = pkgs.fetchFromGitHub {
            owner = "THMonster";
            repo = "dmlive";
            rev = "3736d83ac0920de78ac82fe331bc6b16dc72b5cd"; # no tag
            hash = "sha256-3agUeAv6Nespn6GNw4wmy8HNPQ0VIgZAMnKiV/myKbA=";
          };
          cargoDeps = oldAttrs.cargoDeps.overrideAttrs (_: {
            inherit src;
            outputHash = "sha256-66rkD4K55DLArn0a1QkxtbRCqkTxTTHPffIEeXOhQJE=";
          });
        }))
        libation

        # chat
        (make-webapp "element" "https://app.element.io")
        (make-webapp "slack" "https://app.slack.com/client")
        (make-webapp "discord" "https://discord.com/app")
        (make-webapp "telegram" "https://web.telegram.org")
      ];
    };
}
