{ config, lib, pkgs, modulesPath, self, ... }:
let edg = config.myos.data.fqdn.edg; in
{
  networking.firewall.enable = false;

  myos.tmux.enable = true;
  myos.singbox = {
    enable = true;
    profile = "sstls";
  };
  myos.metrics.enable = true;
}
