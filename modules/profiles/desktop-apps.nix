s@{ pkgs, lib, ... }:
lib.mkProfile s "desktop-apps"
{
  myos.firefox.enable = true;

  # file manager
  services.gvfs.enable = true;
  programs.thunar.enable = true;

  myhome = { config, ... }:
    let
      brave-pkg = (pkgs.brave.override { commandLineArgs = "--gtk-version=4"; });
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
        package =
          (pkgs.symlinkJoin {
            name = "brave";
            meta.mainProgram = "brave";
            paths = [ brave-pkg ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/brave \
                --set GTK_IM_MODULE "fcitx"

              for desktop in "$out/share/applications/"*".desktop"; do
                sed -i "s|${brave-pkg}|$out|g" "$desktop"
              done
            '';
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
