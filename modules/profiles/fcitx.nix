s@{ config, pkgs, lib, self, ... }:
let
  toYAML = lib.generators.toYAML { };
in
lib.mkProfile s "fcitx"
{
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-data
            my.rime-pinyin-zhwiki
          ];
        })
      ];
      settings.inputMethod = {
        "Groups/0" = {
          "Name" = "Default";
          "Default Layout" = "us";
          "DefaultIM" = "rime";
        };
        "Groups/0/Items/0"."Name" = "keyboard-us";
        "Groups/0/Items/1"."Name" = "rime";
        "GroupOrder"."0" = "Default";
      };
    };
  };

  myhome = {
    gtk = {
      gtk3.extraConfig = {
        gtk-im-module = "fcitx";
      };
      gtk4.extraConfig = {
        gtk-im-module = "fcitx";
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
