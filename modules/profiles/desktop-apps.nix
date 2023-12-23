s@{ config, pkgs, lib, ... }:

let
  make-webapp = name: app: (pkgs.makeDesktopItem {
    inherit name;
    desktopName =
      (lib.strings.toUpper (builtins.substring 0 1 name)) +
      (builtins.substring 1 (-1) name);
    exec = "${pkgs.brave}/bin/brave --new-window --window-name=\"chat-web-${name}\" \"${app}\"";
  });
in
lib.mkProfile s "desktop-apps"
{
  myos.firefox.enable = true;

  myhome = { config, ... }: {

    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
        { id = "knheggckgoiihginacbkhaalnibhilkk"; } # notion-web-clipper
        { id = "bhhhlbepdkbapadjdnnojkbgioiodbic"; } # solflare-wallet
        { id = "ljobjlafonikaiipfkggjbhkghgicgoh"; } # edit-with-emacs
        {
          id = "dcpihecpambacapedldabdbpakmachpb";
          updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml";
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
