# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let user = config.myos.user.mainUser; in
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "a658e17d";

  myos.desktop.enable = true;
  myos.user.extraGroups = [ "input" ];
  myos.git.enable = true;
  myos.gnupg.enable = true;
  myos.tailscale.enable = true;

  jovian = {
    devices.steamdeck.enable = true;
    steam = {
      enable = true;
      autoStart = true;
      user = user;
      desktopSession = "gamescope-wayland";
    };
  };

  services.getty.autologinUser = user;

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    steamdeck-firmware
  ];
}
