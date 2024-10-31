# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "2aaaac5b";

  myos.desktop.enable = true;
  myos.sway.enable = true;
  myos.fcitx.enable = true;

  myos.tmux.enable = true;
  myos.gaming.enable = false;

  myos.qqqemacs.enable = true;

  myos.alacritty.enable = true;
  myos.shell.enable = true;
  myos.git.enable = true;
  myos.ssh.enable = true;
  myos.gnupg.enable = true;
  myos.desktop-apps.enable = true;
  myos.tools.enable = true;

  myos.clash-meta.enable = true;
  myos.tailscale.enable = true;

  # myos.metrics = {
  #   enable = true;
  #   chugou = true;
  # };

  services.blueman.enable = true;

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  # # Enable sound. Wayland only
  # hardware.pulseaudio.enable = false;
  # services.pipewire = {
  #   enable = true;
  #   alsa = {
  #     enable = true;
  #     support32Bit = true;
  #   };
  #   pulse.enable = true;
  # };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  environment = {
    sessionVariables = {
      RADV_PERFTEST = "sam";
    };

    systemPackages = with pkgs; [
      lm_sensors
      my.hello-custom
      # pw-volume
      ncspot
      pavucontrol
      gtk3

      linux-manual
      man-pages
    ];
  };
}
