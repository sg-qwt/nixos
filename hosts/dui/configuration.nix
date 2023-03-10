{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    ../../modules/mixins/azurebase.nix
  ];

  myos.common.enable = true;
  myos.users.enable = true;
  myos.tmux.enable = true;
  services.fail2ban.enable = true;
}
