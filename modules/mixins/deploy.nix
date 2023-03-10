{ config, lib, pkgs, rootPath, ... }:
{
  system.stateVersion = "22.05";
  nix.settings.trusted-users = [ "@wheel" "deploy" ];
  nix.extraOptions = "experimental-features = nix-command flakes";

  services.openssh = {
    enable = true;
    settings = {
      kbdInteractiveAuthentication = false;
      passwordAuthentication = false;
      permitRootLogin = lib.mkForce "no";
    };
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

  # https://github.com/cole-h/nixos-config/blob/colmena/modules/config/deploy.nix
  users.groups.deploy = {};
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
        {
          command = "/nix/store/*/bin/switch-to-configuration";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-env";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-store";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
