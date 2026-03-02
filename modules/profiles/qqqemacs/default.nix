s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "qqqemacs" {
  myos.langs = {
    clojure = true;
    rust = true;
  };

  environment = {
    systemPackages = [
      pkgs.my.qqqemacs
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

  
