s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "qqqemacs"
  (
    let
      gpt-host = "${config.myos.data.az-anu-domain}.openai.azure.com";
      github-ai = "models.inference.ai.azure.com";
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
          machine ${github-ai} login apikey password ${config.vaultix.placeholder.github-ai-pat}
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

      environment = {
        systemPackages = [
          self.packages.${pkgs.system}.qqqemacs
        ];
      };

      myhome = { config, osConfig, ... }: {
        home.sessionVariables.EDITOR = "emacsclient -t";

        xdg.configFile."eca/config.json" = {
          text = builtins.toJSON {
            defaultBehavior = "plan";
            defaultModel = "azure/gpt-5-mini";
            providers = {
              azure = {
                api = "openai-responses";
                url = "https://${gpt-host}";
                keyEnv = "ECA_AZ_OPENAI_KEY";
                completionUrlRelativePath = "/openai/v1/responses";
                models = {
                  gpt-5-mini = { };
                };
              };
            };
          };
        };

        programs.bash.initExtra = ''

          export ECA_AZ_OPENAI_KEY="$(cat ${osConfig.vaultix.secrets.eca-openai-key.path})"

          if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
            source ${pkgs.emacsPackages.vterm}/share/emacs/site-lisp/elpa/vterm-*/etc/emacs-vterm-bash.sh
          fi
        '';
      };
    }
  )

  
