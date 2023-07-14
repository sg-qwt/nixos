s@{ config, pkgs, lib, ... }:
lib.mkProfile s "alacritty"
{
  home-manager.users."${config.myos.users.mainUser}" = {
    programs.alacritty = {
      enable = true;
      settings = {
        colors = {
          primary = {
            background = "#040404";
            foreground = "#c5c8c6";
          };
        };
        selection.save_to_clipboard = true;
        window = {
          opacity = 0.8;
          dynamic_title = true;
          decorations = "full";
          dimensions = {
            columns = 80;
            lines = 24;
          };
          padding = {
            x = 5;
            y = 5;
          };
        };
      };
    };
  };
}
