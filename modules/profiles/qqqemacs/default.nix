s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "qqqemacs"
  (
    let
      gpt-host = "zaizhiwanwudev.openai.azure.com";
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

      myhome = { config, ... }: {
        home.sessionVariables.EDITOR = "emacsclient -t";

        programs.bash.initExtra = ''
          if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
            source ${pkgs.emacsPackages.vterm}/share/emacs/site-lisp/elpa/vterm-*/etc/emacs-vterm-bash.sh
          fi
        '';
      };
    }
  )

  
