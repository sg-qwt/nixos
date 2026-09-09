{ config, pkgs, lib, ... }:
{
  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;

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
    aitooling.enable = true;
    printing.enable = true;
  };
}
