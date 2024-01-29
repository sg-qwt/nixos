s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "qqqemacs"
  (
    let
      inherit (config.myos.data) openai;
      gpt-host = "zaizhiwanwudev.openai.azure.com";
      init-el = pkgs.substituteAll {
        src = ./init.el;
        authFile = config.sops.templates.authinfo.path;
        gptHost = gpt-host;
        gptDeployment = openai.deployment;
      };
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
        ] ++

        (with epkgs.melpaStablePackages; [
          clojure-mode
          clojure-mode-extra-font-locking
          cider
          cider-eval-sexp-fu

          markdown-mode
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
          company # for company backends

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
          yasnippet-capf

          ibuffer-vc

          vterm
          multi-vterm

          hl-todo

          rust-mode

          gptel

          edit-server

          telega
        ]) ++

        (with epkgs.elpaPackages; [
          vertico
          corfu
          nftables-mode
          jarchive
          which-key
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

      sops.secrets.openai_key.sopsFile = self + "/secrets/tfout.json";
      sops.templates.authinfo.content = ''
        machine ${gpt-host} login apikey password ${config.sops.placeholder.openai_key}
      '';
      sops.templates.authinfo.owner = config.myos.user.mainUser;

      myos.sdcv-with-dicts.enable = true;

      myos.langs = {
        clojure = true;
        rust = true;
        nix = true;
      };

      environment = {
        systemPackages = with pkgs; [
          qqqemacs

          search-epkgs
          # consult-ripgrep
          ripgrep
          (aspellWithDicts (ds: with ds; [ en ]))

          # needed by markdown-mode
          discount

          # needed by nov.el
          unzip

          self.packages.${pkgs.system}.bento
        ];
      };

      myhome = { config, ... }: {
        xdg.configFile."emacs/init.el".source = init-el;

        xdg.configFile."emacs/snippets" = {
          source = ./snippets;
          recursive = true;
        };

        home.sessionVariables.EDITOR = "emacsclient -t";
      };
    }
  )
