{ config, lib, pkgs, ... }:

with lib;

let cfg = config.myos.ssh;
in {
  options.myos.ssh = {
    enable = mkEnableOption "ssh config";
  };

  config = mkIf cfg.enable {
    home-manager.users."${config.myos.users.mainUser}" = {
      programs.ssh = {
        enable = true;
        serverAliveInterval = 60;
        matchBlocks = {
          dui = {
            hostname = "dui.${config.myos.data.fqdn.edg}";
            user = "me";
          };
        };
      };
    };
  };
}
