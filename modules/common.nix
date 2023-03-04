{ config, pkgs, lib, helpers, inputs, self, ... }:
helpers.mkModule config lib
  "common"
  "NixOS commons"
{
  nix = {
    package = pkgs.nixVersions.stable;

    registry.nixpkgs.flake = inputs.nixpkgs;
    registry.myos.flake = self;

    extraOptions = "experimental-features = nix-command flakes";

    settings = {
      nix-path = [ "nixpkgs=${inputs.nixpkgs}" ];

      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
        "https://jovian-nixos-zhaofengli.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "jovian-nixos-zhaofengli.cachix.org-1:JL2uhBo5bJnVxLfMUjkxmoQsp9K2OFWQiZUnlnjX9x4="
      ];

      auto-optimise-store = true;
      trusted-users = [ "@wheel" "deployment" ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      dates = "weekly";
    };
  };

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";

    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
      "zh_CN/GB2312"
      "zh_CN.GBK/GBK"
      "zh_CN.GB18030/GB18030"
      "zh_TW.UTF-8/UTF-8"
      "zh_TW/BIG5"
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

    # enableDefaultFonts = true;
    # fontconfig.defaultFonts = {
    #   emoji = [ "Noto Color Emoji" ];
    #   monospace = [ "Source Han Mono" ];
    #   # sansSerif = [ "Noto Sans CJK SC" ];
    #   sansSerif = [
    #     "Noto Sans CJK JP"
    #     "Noto Sans CJK KR"
    #     "Noto Sans CJK HK"
    #     "Noto Sans CJK SC"
    #     "Noto Sans CJK TC"
    #   ];
    #   serif = [ "Source Han Serif" ];
    # };

  };
}
