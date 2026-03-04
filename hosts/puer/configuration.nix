{ config, lib, pkgs, modulesPath, self, ... }:
{
  networking.firewall.enable = false;

  myos.tmux.enable = true;
  myos.singbox = {
    enable = true;
    profile = "sstls";
  };
  myos.metrics.enable = true;
}
