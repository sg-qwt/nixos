s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "qqqemacs"
  (
    let
      gpt-host = "${config.myos.data.az-anu-domain}.openai.azure.com";
      json = pkgs.formats.json { };

      eca-config = json.generate "eca-config.json" {
        defaultBehavior = "agent";
        defaultModel = "azure/gpt-5-mini";
        netrcFile = config.vaultix.templates.eca-netrc.path;
        providers = {
          azure = {
            api = "openai-responses";
            url = "https://${gpt-host}";
            completionUrlRelativePath = "/openai/v1/responses";
            keyRc = "${gpt-host}";
            models = {
              gpt-5-mini = { };
            };
          };
        };
      };

      my-eca = (pkgs.symlinkJoin {
        name = "myeca";
        paths = [ self.packages.${pkgs.system}.eca ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/eca \
            --add-flags "--config-file ${eca-config}"
        '';
      });

      eca-bin = lib.getExe' my-eca "eca";
    in
    {
      # sudo mkdir -p /var/cache/man/nixos
      # sudo mandb
      # this slows down builds
      # documentation.man.generateCaches = true; 

      vaultix.secrets.openai-key = { };
      vaultix.secrets.github-ai-pat = { };
      vaultix.templates.authinfo = {
        content = ''
          machine ${gpt-host} login apikey password ${config.vaultix.placeholder.openai-key}
        '';
        owner = config.myos.user.mainUser;
      };

      vaultix.secrets.eca-openai-key = {
        owner = config.myos.user.mainUser;
      };

      myos.sdcv-with-dicts.enable = true;

      myos.langs = {
        clojure = true;
        rust = true;
      };

      vaultix.secrets.eca-openai-key = { };

      vaultix.templates.eca-netrc = {
        content = ''
          machine ${gpt-host}
          password ${config.vaultix.placeholder.eca-openai-key}
        '';
        owner = config.myos.user.mainUser;
      };

      environment = {
        systemPackages = [
          my-eca
          (pkgs.symlinkJoin {
            name = "qqqemacs";
            paths = [ self.packages.${pkgs.system}.qqqemacs ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/emacs \
                --set QQQ_ECA_PATH ${eca-bin} \
                --set QQQ_AUTHINFO ${config.vaultix.templates.authinfo.path}
            '';
          })
        ];
      };

      myhome = { config, osConfig, ... }: {
        home.sessionVariables.EDITOR = "emacsclient -t";

        programs.bash.initExtra = ''
          if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
            source ${pkgs.emacsPackages.vterm}/share/emacs/site-lisp/elpa/vterm-*/etc/emacs-vterm-bash.sh
          fi
        '';
      };
    }
  )

  
