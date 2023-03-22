s@{ config, pkgs, lib, helpers, rootPath, ... }:
helpers.mkProfile s "qqqemacs"
  (
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
          cape
          command-log-mode
          magit
          nix-mode
          hcl-mode
        ]) ++
        (with epkgs.elpaPackages; [
          use-package
          vertico
        ]));
      search-epkgs = pkgs.writeShellScriptBin "search-epkgs" ''
        (nix search nixpkgs#emacs.pkgs.melpaStablePackages $*
        nix search nixpkgs#emacs.pkgs.melpaPackages $*
        nix search nixpkgs#emacs.pkgs.elpaPackages $*
        nix search nixpkgs#emacs.pkgs.orgPackages $*) 2> /dev/null
      '';
    in
    {
      # sudo mkdir -p /var/cache/man/nixos
      # sudo mandb
      # this slows down builds
      # documentation.man.generateCaches = true; 
      environment = {
        systemPackages = with pkgs; [
          search-epkgs
          ripgrep
          qqqemacs
        ];
      };

      home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
        xdg.configFile."emacs/init.el".source = (rootPath + "/config/qqqemacs/init.el");

        home.sessionVariables.EDITOR = "${qqqemacs}/bin/emacs";
      };
    }
  )
