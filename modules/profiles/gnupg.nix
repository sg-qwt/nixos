s@{ pkgs-latest, lib, self, ... }:
lib.mkProfile s "gnupg" {

  services.pcscd.enable = true;

  myhome = {

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
      pinentryPackage = pkgs-latest.wayprompt;
      extraConfig = ''
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
    };
  };
}
