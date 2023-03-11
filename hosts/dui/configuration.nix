{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    ../../modules/mixins/azurebase.nix
  ];

  networking.firewall.enable = false;

  myos.common.enable = true;
  myos.users.enable = true;
  myos.tmux.enable = true;
  myos.ssserver.enable = true;
  services.fail2ban.enable = true;


}
