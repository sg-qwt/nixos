s@{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkProfile s "fcitx" {
  # systemd.user.services.fcitx5-gamescope-helper = lib.mkIf config.myos.gaming.enable {
  #   description = "Fcitx candidate popups and DPI for Gamescope";
  #   wantedBy = [ "graphical-session.target" ];
  #   partOf = [ "graphical-session.target" ];
  #   after = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     ExecStart = "${lib.getExe pkgs.my.fcitx5-gamescope-helper} --dpi 192";
  #     Restart = "on-failure";
  #     RestartSec = 3;
  #   };
  # };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-pinyin-zhwiki
      ];
      ignoreUserConfig = true;
      settings = {
        inputMethod = {
          "Groups/0" = {
            "Name" = "Default";
            "Default Layout" = "us";
            "DefaultIM" = "pinyin";
          };
          "Groups/0/Items/0"."Name" = "keyboard-us";
          "Groups/0/Items/1"."Name" = "pinyin";
          "GroupOrder"."0" = "Default";
        };
        addons = {
          pinyin.globalSection = {
            EmojiEnabled = "True";
            CloudPinyinEnabled = "False";
            FirstRun = "False";
            PageSize = 9;
          };
        };
      };
    };
  };
}
