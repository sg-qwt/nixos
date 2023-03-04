{ config, pkgs, lib, helpers, inputs, ... }:
helpers.mkModule config lib
  "spacemacs"
  "spacemacs"
{
  fonts.fonts = with pkgs; [
    source-code-pro
    nanum-gothic-coding
    emacs-all-the-icons-fonts
  ];

  services.emacs = {
    enable = true;
    package = pkgs.emacsPgtkNativeComp;
    defaultEditor = true;
  };

  home-manager.users."${config.myos.users.mainUser}" = {
    home.file = {
      ".emacs.d" = {
        source = inputs.spacemacs;
        recursive = true;
      };

      ".spacemacs.d/init.el" = {
        source = ../config/spacemacs.d/init.el;
      };
    };

    home.packages = with pkgs; [
      git
      ripgrep
      (aspellWithDicts (ds: with ds; [ en ]))

      # (writeShellScriptBin "spacemacs"
      #   (import ../config/scripts/spacemacs.nix { inherit pkgs; }))
    ];
  };
}
