# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, lib, ... }:

{

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "2aaaac5b";

  myos.sway.enable = true;

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


  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.adb.enable = true;
  users.users.me.extraGroups = [ "adbusers" ];

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
