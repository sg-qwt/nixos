{ config, lib, pkgs, self, ... }:
{
  system.stateVersion = "22.11";
  nix.settings = {
    trusted-users = [ "@wheel" "deploy" ];

    experimental-features = [
      "nix-command"
      "flakes"
      "repl-flake"
      "ca-derivations"
    ];

    warn-dirty = false;
    fallback = true;
    connect-timeout = 5;
    log-lines = 25;
    auto-optimise-store = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkForce "no";
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
      (self + "/resources/keys/ssh-me.pub")
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
