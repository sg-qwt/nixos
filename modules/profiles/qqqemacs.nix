s@{ config, pkgs, lib, helpers, rootPath, ... }:
helpers.mkProfile s "qqqemacs"
let
  myEmacs = pkgs.emacs; 
  emacsWithPackages = (pkgs.emacsPackagesFor myEmacs).emacsWithPackages; 
  qqqemacs = emacsWithPackages (epkgs:
    (with epkgs.melpaStablePackages; [ 
      modus-themes
    ]) ++
    (with epkgs.melpaPackages; [ 
      evil
      evil-collection
      general
      orderless
      marginalia
      consult
      command-log-mode
      magit
      nix-mode
    ]) ++
    (with epkgs.elpaPackages; [ 
      use-package
      vertico
    ]))
in
{
  documentation.man.generateCaches = true;
  environment = {
    systemPackages = with pkgs; [
      ripgrep
      qqqemacs
    ];
  };

  home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
    xdg.configFile."emacs/init.el".source = (rootPath + "/config/qqqemacs/init.el");

    environment.variables.EDITOR = "${qqqemacs}/bin/emacs";
  };
}
