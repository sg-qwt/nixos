s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "password-store"
{
  home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {

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
