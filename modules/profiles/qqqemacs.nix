s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "qqqemacs"
  (
    let
      # https://github.com/nix-community/emacs-overlay/issues/312
      myEmacs = pkgs.emacs-unstable-pgtk;
      emacsWithPackages = (pkgs.emacsPackagesFor myEmacs).emacsWithPackages;
      qqqemacs = emacsWithPackages (epkgs:

        [(epkgs.treesit-grammars.with-grammars
          (grammars: with grammars;
            [
              tree-sitter-yaml
              tree-sitter-typescript
            ]))] ++

        (with epkgs.melpaStablePackages; [
          clojure-mode
          clojure-mode-extra-font-locking
          cider
          cider-eval-sexp-fu
        ]) ++

        (with epkgs.melpaPackages; [
          modus-themes

          evil
          evil-surround
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

          embark
          embark-consult
          wgrep

          smartparens
          evil-cleverparens

          pdf-tools
          nov

          peep-dired

        ]) ++

        (with epkgs.elpaPackages; [
          vertico
          corfu
          nftables-mode
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
          unzip
          (makeDesktopItem {
            name = "org-protocol";
            exec = "emacsclient --create-frame %u";
            comment = "Org Protocol";
            desktopName = "org-protocol";
            type = "Application";
            mimeTypes = [ "x-scheme-handler/org-protocol" ];
          })
          # lsp servers
          nixd
        ];
      };

      home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
        xdg.configFile."emacs/init.el".source = (self + "/config/qqqemacs/init.el");
      };
    }
  )
