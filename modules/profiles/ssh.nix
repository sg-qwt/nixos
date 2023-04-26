{ config, lib, pkgs, self, ... }:

with lib;

let
  cfg = config.myos.ssh;
  data = config.myos.data;
  match-blocks =
    (builtins.foldl' (a: b: a // b) { }
      (map
        (host: {
          "${host}" = {
            hostname = "${host}.h.${data.fqdn.edg}";
            user = "me";
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
        serverAliveInterval = 60;
        matchBlocks = match-blocks;
        userKnownHostsFile =
          let
            knownHosts = pkgs.writeTextFile {
              name = "known_hosts";
              text = builtins.readFile (self + "/config/known_hosts");
            };
          in
          "~/.ssh/known_hosts ${knownHosts}";
      };
    };
  };
}
