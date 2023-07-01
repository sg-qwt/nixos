s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "fcitx"
{
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      (fcitx5-rime.override {
        rimeDataPkgs = [
          rime-data
          my.rime-pinyin-zhwiki
        ];
      })
    ];
  };

  home-manager.users."${config.myos.users.mainUser}" = {
    xdg.dataFile = {
      "fcitx5/rime/luna_pinyin.custom.yaml".source =
        (self + "/config/rime/luna_pinyin.custom.yaml");
      "fcitx5/rime/luna_pinyin.extended.dict.yaml".source =
        (self + "/config/rime/luna_pinyin.extended.dict.yaml");
    };
  };
}
