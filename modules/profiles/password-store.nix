s@{ config, pkgs, lib, ... }:
lib.mkProfile s "password-store"
{
  myhome = { config, ... }: {

    programs.password-store = {
      enable = true;
      package = (pkgs.pass.override { waylandSupport = true; });
      settings = {
        PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
        PASSWORD_STORE_GENERATED_LENGTH = "10";
      };
    };

    # services.pass-secret-service.enable = true;

    home.packages = with pkgs; [
    ];
  };
}
