{ config, pkgs, lib, ... }:
let
  systemctl = lib.getExe' config.systemd.package "systemctl";
in
{
  services = {
    power-profiles-daemon.enable = true;
    asusd.enable = true;
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
  myos.tailscale.enable = false;
  myos.android.enable = true;

  myos.container.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${systemctl} poweroff"
  '';
}
