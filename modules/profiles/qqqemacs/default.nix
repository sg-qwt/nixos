s@{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  ageIdentity =
    if config.networking.hostName == "li" then
      self + "/resources/keys/age-yubikey-identity-backup.txt"
    else
      self + "/resources/keys/age-yubikey-identity-main.txt";
in
lib.mkProfile s "qqqemacs" {
  myos.langs = {
    clojure = true;
    rust = true;
  };

  environment = {
    systemPackages = [
      (pkgs.my.qqqemacs.override { inherit ageIdentity; })
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
