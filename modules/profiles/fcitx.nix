s@{ config, pkgs, lib, self, ... }:
let
  toYAML = lib.generators.toYAML { };
  toINI = lib.generators.toINI { };
in
lib.mkProfile s "fcitx"
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

  myhome = {
    xdg.configFile = {
      "fcitx5/profile" = {
        force = true;
        text = toINI {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "rime";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "rime";
            Layout = "";
          };
          GroupOrder = {
            "0" = "Default";
          };
        };
      };
    };
    xdg.dataFile = {
      "fcitx5/rime/luna_pinyin.custom.yaml".text = toYAML {
        patch = {
          "translator/dictionary" = "luna_pinyin.extended";
        };
      };
      "fcitx5/rime/luna_pinyin.extended.dict.yaml".text = toYAML {
        name = "luna_pinyin.extended";
        version = "0.1";
        sort = "by_weight";
        use_preset_vocabulary = true;
        import_tables = [
          "luna_pinyin"
          "zhwiki"
        ];
      };
    };
  };
}
