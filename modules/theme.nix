{ config, pkgs, lib, helpers, ... }:
helpers.mkModule config lib
  "theme"
  "gtk theme and cursor theme"
{
  home-manager.users."${config.myos.users.mainUser}" = rec {
    # home.pointerCursor = {
    #   name = "Adwaita";
    #   package = pkgs.gnome.adwaita-icon-theme;
    #   size = 32;
    #   gtk.enable = true;
    # };

    gtk = {
      enable = true;
      theme = {
        name = "Arc";
        package = pkgs.arc-theme;
      };
    };

    home.sessionVariables.GTK_THEME = gtk.theme.name;
  };
}
