s@{ pkgs, pkgs-latest, lib, ... }:
lib.mkProfile s "fcitx"
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = [
        pkgs.fcitx5-chinese-addons
        pkgs-latest.fcitx5-pinyin-zhwiki
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
