{ config, lib, pkgs, rootPath, ... }:

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
      default = [ ];
      description = "Host specific groups";
    };
  };

  config = mkIf cfg.enable {

    users.mutableUsers = false;

    users.users."${cfg.mainUser}" = {
      isNormalUser = true;
      description = "me";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" "systemd-journal" ] ++ cfg.extraGroups;
      passwordFile = config.sops.secrets.me-password.path;
      openssh.authorizedKeys.keyFiles = [
        (rootPath + "/resources/keys/ssh-me.pub")
      ];
    };

    sops.secrets.me-password = {
      sopsFile = rootPath + "/secrets/secrets.yaml";
      neededForUsers = true;
    };

    home-manager.users."${cfg.mainUser}" = {
      home.stateVersion = "22.11";
    };
  };
}
