s@{ config, pkgs, lib, helpers, inputs, self, ... }:
helpers.mkProfile s "desktop"
{
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

  networking = {
    useDHCP = lib.mkDefault true;
    firewall.enable = true;

    nftables = {
      enable = true;
      flushRuleset = false;
    };

    networkmanager = {
      enable = true;
      firewallBackend = "nftables";
    };
  };
}
