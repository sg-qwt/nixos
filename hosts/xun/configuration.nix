{ config, lib, pkgs, modulesPath, self, ... }:
let edg = config.myos.data.fqdn.edg; in
{
  imports = [
    ../../modules/mixins/azurebase.nix
  ];

  networking.firewall.enable = false;

  myos.common.enable = true;
  myos.users.enable = true;
  myos.tmux.enable = true;
}
