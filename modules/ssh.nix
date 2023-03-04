{ config, lib, pkgs, ... }:

with lib;

let cfg = config.myos.ssh;
in {
  options.myos.ssh = {
    enable = mkEnableOption "ssh config";

    openssh.enable = mkEnableOption "OpenSSH server";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home-manager.users."${config.myos.users.mainUser}" = {
        programs.ssh = {
          enable = true;
          matchBlocks = {
            "github.com" = {
              hostname = "ssh.github.com";
              port = 443;
              user = "git";
              identityFile = [ "~/.ssh/yubikey.pub" ];
            };
          };
        };
      };
    })

    (mkIf cfg.openssh.enable {
      services.openssh = {
        enable = true;
        kbdInteractiveAuthentication = false;
        passwordAuthentication = false;
        permitRootLogin = "no";
        hostKeys = [
          {
            bits = 4096;
            path = "/etc/ssh/ssh_host_rsa_key";
            type = "rsa";
          }
          {
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };
    })

  ];
}
