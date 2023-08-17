s@{ config, pkgs, sources, lib, self, ... }:
lib.mkProfile s "qqqemacs"
  (
    let
      myEmacs = (if config.myos.wayland.enable then pkgs.emacs29-pgtk else pkgs.emacs29);
      emacsWithPackages = (pkgs.emacsPackagesFor myEmacs).emacsWithPackages;
      qqqemacs = emacsWithPackages (epkgs:
        [
          (epkgs.treesit-grammars.with-grammars
            (grammars: with grammars;
            [
              tree-sitter-yaml
              tree-sitter-typescript
            ]))

          (epkgs.trivialBuild {
            inherit (sources.cape-yasnippet) pname version src;
            packageRequires = with epkgs; [
              cape
              yasnippet
              cl-lib
            ];
          })
        ] ++

        (with epkgs.melpaStablePackages; [
          clojure-mode
          clojure-mode-extra-font-locking
          cider
          cider-eval-sexp-fu
        ]) ++

        (with epkgs.melpaPackages; [
          # TODO remove after emacs 30
          modus-themes

          avy
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

          # TODO replacde with dired-preview
          peep-dired

          yasnippet

          ibuffer-vc

          vterm
          multi-vterm

          hl-todo
        ]) ++

        (with epkgs.elpaPackages; [
          vertico
          corfu
          nftables-mode
          jarchive
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

      myos.sdcv-with-dicts.enable = true;

      environment = {
        systemPackages = with pkgs; [
          qqqemacs

          search-epkgs
          # consult-ripgrep
          ripgrep
          (aspellWithDicts (ds: with ds; [ en ]))

          # needed by nov.el
          unzip

          (makeDesktopItem {
            name = "org-protocol";
            exec = "emacsclient --create-frame %u";
            comment = "Org Protocol";
            desktopName = "org-protocol";
            type = "Application";
            mimeTypes = [ "x-scheme-handler/org-protocol" ];
          })
          self.packages.x86_64-linux.grab-shi

          # lsp servers
          nil
          clojure-lsp
        ];
      };

      home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {

        systemd.user.services.emacs.Unit.X-RestartIfChanged = lib.mkForce true;
        systemd.user.services.emacs.Unit.X-Restart-Triggers = [ "${./init.el}" ];
        services.emacs = {
          enable = true;
          package = qqqemacs;
          startWithUserSession = "graphical";
          defaultEditor = true;
        };

        xdg.configFile."emacs/init.el".source = ./init.el;
        xdg.configFile."emacs/snippets" = {
          source = ./snippets;
          recursive = true;
        };
      };
    }
  )
