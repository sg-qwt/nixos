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

      sops.secrets.openai_key.sopsFile = self + "/secrets/tfout.json";
      sops.secrets.github-ai-pat.sopsFile = self + "/secrets/secrets.yaml";
      sops.templates.authinfo.content = ''
        machine ${gpt-host} login apikey password ${config.sops.placeholder.openai_key}
        machine ${github-ai} login apikey password ${config.sops.placeholder.github-ai-pat}
      '';
      sops.templates.authinfo.owner = config.myos.user.mainUser;

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

  
