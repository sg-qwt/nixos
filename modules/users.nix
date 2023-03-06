{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myos.users;
in
{
  options.myos.users = {
    enable = mkEnableOption "Users config";

    mainUser = mkOption {
      type = types.str;
      default = "me";
      description = "Main user";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Host specific groups";
    };
  };

  config = mkIf cfg.enable {

    users.mutableUsers = false;

    users.groups.deployment = {};
    users.users.deployment = {
      isSystemUser = true;
      openssh.authorizedKeys.keyFiles = [
        ../resources/keys/ssh-me.pub
      ];
      group = "deployment";
      shell = pkgs.bash;
    };

    users.users."${cfg.mainUser}" = {
      isNormalUser = true;
      description = "me";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" "systemd-journal" ] ++ cfg.extraGroups;
      passwordFile = config.sops.secrets.me-password.path;
      openssh.authorizedKeys.keyFiles = [
        ../resources/keys/ssh-me.pub
      ];
    };

    # https://github.com/cole-h/nixos-config/blob/colmena/modules/config/deploy.nix
    security.sudo.extraRules = [
      {
        users = [ "deployment" ];
        commands = [
          {
            command = "/nix/store/*/bin/switch-to-configuration";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-env";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    sops.secrets.me-password = {
      sopsFile = ../secrets/secrets.yaml;
      neededForUsers = true;
    };

    home-manager.users."${cfg.mainUser}" = {
      home.stateVersion = "22.11";
    };

  };
}
