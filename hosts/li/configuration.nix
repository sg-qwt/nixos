{ config, pkgs, lib, ... }:
{
  jovian.devices.steamdeck.enableOsFanControl = true;
  systemd.tmpfiles.settings."99-jovian"."/sys/firmware/dmi/tables/*".z.mode = "444";
  systemd.tmpfiles.rules = [
    "z /sys/class/dmi/id/product_serial 440 root wheel - -"
    "z /sys/class/dmi/id/board_serial 440 root wheel - -"
  ];
  services.power-profiles-daemon.enable = true;

  # services.fwupd = {
  #   enable = true;
  #   daemonSettings = {
  #     OnlyTrusted = false;
  #   };
  # };

  myos = {
    sway.enable = true;
    tmux.enable = true;
    qqqemacs.enable = true;
    shell.enable = true;
    git.enable = true;
    ssh.enable = true;
    desktop-apps.enable = true;
    tools.enable = true;
    clash-meta.enable = true;
    tailscale.enable = true;
    android.enable = true;
    gaming.enable = true;
    aitooling.enable = true;
    printing.enable = true;
  };
}
