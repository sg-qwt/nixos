{ config, pkgs, lib, helpers, inputs, self, ... }:
helpers.mkModule config lib
  "desktop"
  "desktop specific"
{
  nix.settings = {
    substituters = lib.mkBefore [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
    ];
  };

  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;

    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      source-han-mono
      source-han-sans
      source-han-serif
      wqy_microhei
      wqy_zenhei
      liberation_ttf
    ];
  };
}
