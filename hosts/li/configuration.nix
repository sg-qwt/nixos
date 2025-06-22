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
  myos.tailscale.enable = true;
  myos.android.enable = true;

  myos.container.enable = true;

  services.udev = {
    # fixes mic mute button
    extraHwdb = ''
      evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
      KEYBOARD_KEY_ff31007c=f20
    '';
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{idVendor}=="0b05", ATTR{idProduct}=="19b6", ATTR{power/autosuspend}="-1"
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", ATTR{idProduct}=="193b", ATTR{power/wakeup}="disabled"
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${systemctl} poweroff"
    '';
  };
}
