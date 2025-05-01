{ lib, pkgs, pkgs-latest, self, ... }:
{
  system.stateVersion = "24.11";

  nix.settings = {
    trusted-users = [ "@wheel" "deploy" ];

    experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
    ];

    warn-dirty = false;
    fallback = true;
    connect-timeout = 5;
    log-lines = 25;
    auto-optimise-store = true;
  };

  services.userborn.enable = true;

  programs.ssh.package = pkgs-latest.openssh;
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = false;
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

  # some commons from https://github.com/nix-community/srvos/blob/main/nixos/common
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  programs.ssh.knownHosts = {
    "github.com".hostNames = [ "github.com" ];
    "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

    "gitlab.com".hostNames = [ "gitlab.com" ];
    "gitlab.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

    "git.sr.ht".hostNames = [ "git.sr.ht" ];
    "git.sr.ht".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
  };
}
