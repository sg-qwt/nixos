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
          evil-org
          general
          orderless
          marginalia
          consult
          cape
          command-log-mode
          magit
          nix-mode
          hcl-mode

          org-roam

          smartparens
          evil-cleverparens

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

      services.emacs = {
        enable = true;
        defaultEditor = true;
        package = qqqemacs;
      };

      environment = {
        systemPackages = with pkgs; [
          search-epkgs
          ripgrep
          (aspellWithDicts (ds: with ds; [ en ]))
          (makeDesktopItem {
            name = "org-protocol";
            exec = "emacsclient %u";
            comment = "Org Protocol";
            desktopName = "org-protocol";
            type = "Application";
            mimeTypes = [ "x-scheme-handler/org-protocol" ];
          })
        ];
      };

      home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
        xdg.configFile."emacs/init.el".source = (rootPath + "/config/qqqemacs/init.el");
      };
    }
  )
