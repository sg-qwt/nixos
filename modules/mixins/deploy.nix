{ config, lib, pkgs, rootPath, ... }:
{
  system.stateVersion = "22.05";
  nix.settings.trusted-users = [ "@wheel" "deploy" ];
  nix.extraOptions = "experimental-features = nix-command flakes repl-flake";

  services.openssh = {
    enable = true;
    settings = {
      kbdInteractiveAuthentication = false;
      passwordAuthentication = false;
      permitRootLogin = lib.mkForce "no";
    };
    extraConfig = ''
      Match User deploy
        AllowAgentForwarding no
        AllowTcpForwarding no
        PermitTTY no
        PermitTunnel no
        X11Forwarding no
      Match All
    '';
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

  users.groups.deploy = { };
  users.users.deploy = {
    isSystemUser = true;
    openssh.authorizedKeys.keyFiles = [
      (rootPath + "/resources/keys/ssh-me.pub")
    ];
    group = "deploy";
    shell = pkgs.bash;
  };

  security.sudo.extraRules = [
    {
      users = [ "deploy" ];
      commands = [
        { command = "ALL"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}