s@{ config, pkgs, lib, helpers, inputs, rootPath, ... }:
helpers.mkProfile s "spacemacs"
{
  fonts.fonts = with pkgs; [
    source-code-pro
    nanum-gothic-coding
    emacs-all-the-icons-fonts
  ];

  services.emacs = {
    enable = true;
    package = pkgs.emacs;
    defaultEditor = false;
  };

  home-manager.users."${config.myos.users.mainUser}" = {
    home.file = {
      ".emacs.d" = {
        source = inputs.spacemacs;
        recursive = true;
      };

      ".spacemacs.d/init.el" = {
        source = (rootPath + "/config/spacemacs.d/init.el");
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
