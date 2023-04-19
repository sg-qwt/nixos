s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "gnupg" {

  home-manager.users."${config.myos.users.mainUser}" = {

    programs.gpg = {
      enable = true;

      settings = {
        keyserver = "hkps://keys.openpgp.org";
      };

      publicKeys = [
        {
          source = (self + "/resources/keys/openpgp-me.asc");
          trust = 5;
        }
      ];
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      sshKeys = [ "5DA83E8DA781EFD4F4E5B5D6886B1E6B279152DF" ];
      extraConfig = ''
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
    };
  };
}
