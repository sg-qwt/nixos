# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, ... }:

{
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "2aaaac5b";

  services.pcscd.enable = true;

  myos.common.enable = true;
  myos.desktop.enable = true;
  myos.users.enable = true;
  # myos.sway.enable = true;
  myos.fcitx.enable = true;
  myos.gnome.enable = true;
  myos.wayland.enable = true;
  # myos.ibus.enable = true;

  myos.tmux.enable = true;
  myos.gaming.enable = true;

  myos.qqqemacs.enable = true;

  myos.alacritty.enable = true;
  myos.shell.enable = true;
  myos.git.enable = true;
  myos.ssh.enable = true;
  myos.gnupg.enable = true;
  myos.desktop-apps.enable = true;
  myos.clojure-dev.enable = true;
  myos.tools.enable = true;
  myos.theme.enable = true;

  myos.clash-meta.enable = true;
  myos.tailscale.enable = true;


  services.blueman.enable = true;

  programs.thunar.enable = true;

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  # Enable sound.
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    # extraPackages = with pkgs; [
    #   amdvlk
    # ];
    # extraPackages32 = with pkgs; [
    #   driversi686Linux.amdvlk
    # ];
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

      oranc
    ];


    etc."sensors.d/it87.conf".source = (self + "/config/sensors/it87.conf");
  };
}
