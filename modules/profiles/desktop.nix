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
    extraConfig.pipewire = {
      "99-disable-bell"."context.properties"."module.x11.bell" = false;
    };
    wireplumber.extraConfig."99-hdmi-fix"."monitor.alsa.rules" = [
      {
        matches = [{ "node.name" = "alsa_output.pci-0000_65_00.1.hdmi-stereo-extra2"; }];
        actions.update-props = {
          "api.alsa.period-size" = 2048;
          "api.alsa.headroom" = 8192;
          "session.suspend-timeout-seconds" = 0;
        };
      }
    ];
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
