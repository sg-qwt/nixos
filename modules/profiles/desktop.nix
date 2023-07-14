s@{ config, pkgs, lib, inputs, self, ... }:
lib.mkProfile s "desktop"
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

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
}
