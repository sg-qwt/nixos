s@{ config, pkgs, lib, helpers, inputs, rootPath, ... }:
helpers.mkProfile s "doom-emacs"
{
  services.emacs = {
    enable = true;
    package = pkgs.emacs;
    defaultEditor = false;
  };

  fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];

  home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
    home.file = {
      ".config/emacs" = {
        source = inputs.doomemacs;
        recursive = true;
      };

      ".config/doom" = {
        source = (rootPath + "/config/doom-emacs");
      };
    };
    home = {
      packages = with pkgs; [
        ripgrep
        (aspellWithDicts (ds: with ds; [ en ]))
      ];
    };

    home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
    home.sessionVariables.EMACSDIR = "${config.xdg.configHome}/emacs";
    home.sessionVariables.DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
  };
}
