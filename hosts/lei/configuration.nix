# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  systemctl = lib.getExe' config.systemd.package "systemctl";
in
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  hardware.firmware = [ pkgs.sof-firmware ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  services.acpid = {
    enable = true;
    handlers = {
      headphone-fix-noise = {
        event = "jack/headphone HEADPHONE plug";
        action = "${pkgs.alsa-tools}/bin/hda-verb /dev/snd/hwC0D0 0x1d SET_PIN_WIDGET_CONTROL 0x0";
      };
    };
  };

  services.fwupd.enable = true;

  myos.sway.enable = true;

  myos.tmux.enable = true;
  myos.qqqemacs.enable = true;

  myos.shell.enable = true;
  myos.git.enable = true;
  myos.ssh.enable = true;
  myos.desktop-apps.enable = true;
  myos.tools.enable = true;

  myos.clash-meta.enable = true;
  myos.tailscale.enable = true;
  myos.android.enable = true;

  myos.container.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${systemctl} poweroff"
  '';
}
