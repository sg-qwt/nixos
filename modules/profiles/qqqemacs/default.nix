s@{ config, pkgs, sources, lib, self, ... }:
lib.mkProfile s "qqqemacs"
  (
    let
      inherit (config.myos.data) openai;
      gpt-host = "eastus.api.cognitive.microsoft.com";
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

          # TODO https://github.com/karthink/gptel/pull/104
          (gptel.overrideAttrs (old: {
            src = pkgs.fetchFromGitHub {
              owner = "doctorguile";
              repo = "gptel";
              rev = "9a3311473eecd6df5ef7f58f8a863a3bc0cbcb38";
              sha256 = "sha256-O+iaPOriNTrcb+aKJFUzf77+Emry7kqHsNrgsWC3iDo=";
            };
          }))
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
      sops.templates.authinfo.owner = config.myos.users.mainUser;

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

          (makeDesktopItem {
            name = "org-protocol";
            exec = "emacsclient --create-frame %u";
            comment = "Org Protocol";
            desktopName = "org-protocol";
            type = "Application";
            mimeTypes = [ "x-scheme-handler/org-protocol" ];
          })
          self.packages.x86_64-linux.grab-shi
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

        xdg.configFile."emacs/init.el".source = init-el;

        xdg.configFile."emacs/snippets" = {
          source = ./snippets;
          recursive = true;
        };
      };
    }
  )
