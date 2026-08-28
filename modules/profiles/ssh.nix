{ pkgs, config, lib, self, ... }:

with lib;

let
  cfg = config.myos.ssh;
  username = config.myos.user.mainUser;
  match-blocks =
    {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = true;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlMaster = "auto";
        controlPersist = "1m";
      };
    } //
    (builtins.foldl' (a: b: a // b) { }
      (map
        (host: {
          "${host}" = {
            HostName = "${host}.h.${self.tfo.fqdn.edg}";
            User = username;
          };
        })
        (builtins.attrNames self.shared-data.hosts)));
in
{
  options.myos.ssh = {
    enable = mkEnableOption "ssh config";
  };

  config = mkIf cfg.enable {

    # for yubikey PIV
    services.pcscd.enable = true;

    programs.ssh = {
      startAgent = true;
      enableAskPassword = true;
      askPassword = lib.getExe pkgs.lxqt.lxqt-openssh-askpass;
    };

    myhome = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            ForwardAgent = false;
            AddKeysToAgent = "no";
            Compression = true;
            ServerAliveInterval = 60;
            ServerAliveCountMax = 3;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlMaster = "auto";
            ControlPersist = "1m";
          };
          "github.com" = {
            HostName = "ssh.github.com";
            Port = 443;
            User = "git";
          };
        } //
        (builtins.foldl' (a: b: a // b) { }
          (map
            (host: {
              "${host}" = {
                HostName = "${host}.h.${self.tfo.fqdn.edg}";
                User = username;
              };
            })
            (builtins.attrNames self.shared-data.hosts)));
      };
    };
  };
}
