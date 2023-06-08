s@{ config, pkgs, lib, helpers, inputs, self, ... }:
helpers.mkProfile s "desktop"
{
  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;

    fonts = with pkgs; [
      jetbrains-mono
      lxgw-wenkai
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      hanazono
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
