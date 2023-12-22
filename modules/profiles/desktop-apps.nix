s@{ config, pkgs, lib, ... }:
lib.mkProfile s "desktop-apps"
{
  myos.firefox.enable = true;

  myhome = {

    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      commandLineArgs = [
        # TODO not working with brave
        "--gtk-version=4"
      ];
      extensions = [
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
        { id = "knheggckgoiihginacbkhaalnibhilkk"; } # notion
        { id = "bhhhlbepdkbapadjdnnojkbgioiodbic"; } # solflare-wallet
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
    ];
  };
}
