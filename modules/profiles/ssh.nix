{ config, lib, ... }:

with lib;

let
  cfg = config.myos.ssh;
  data = config.myos.data;
  username = config.myos.users.mainUser;
  match-blocks =
    (builtins.foldl' (a: b: a // b) { }
      (map
        (host: {
          "${host}" = {
            hostname = "${host}.h.${data.fqdn.edg}";
            user = username;
          };
        })
        data.hosts));
in
{
  options.myos.ssh = {
    enable = mkEnableOption "ssh config";
  };

  config = mkIf cfg.enable {
    home-manager.users."${config.myos.users.mainUser}" = {
      programs.ssh = {
        enable = true;
        compression = true;
        serverAliveInterval = 60;
        matchBlocks = match-blocks;
      };
    };
  };
}
