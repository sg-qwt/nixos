s@{ config, pkgs, lib, inputs, self, ... }:
lib.mkProfile s "desktop"
{
  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;

    packages = with pkgs; [
      jetbrains-mono
      lxgw-wenkai
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      hanazono
    ];
  };

  networking = {
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      checkReversePath = "loose";
    };

    nftables = {
      enable = true;
      flushRuleset = false;
    };

    networkmanager = {
      enable = true;
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
}
