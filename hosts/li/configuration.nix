{ config, pkgs, lib, ... }:
{

  myos.asusd.enable = true;

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

}
