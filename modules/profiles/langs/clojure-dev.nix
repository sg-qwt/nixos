s@{ config, pkgs, lib, self, ... }:
let
  jdk = pkgs.jdk17;
in
lib.mkProfile s "clojure-dev"
{
  programs.java = {
    enable = true;
    package = jdk;
  };

  myhome = { config, ... }: {
    home.packages = with pkgs; [
      (clojure.override { inherit jdk; })
      my.babashka-bin
      neil
      cljfmt
      clojure-lsp
    ];

    programs.bash.bashrcExtra = ''
      _bb_complete() {
        BB_TASKS=$(bb tasks|bb -io '(->> *input* (drop 2) (map #(-> % (str/split #" ") first)))')
        BB_HELP=$(bb help|bb -io '(->> *input* (map #(->> % (re-find #"^  ([-a-z]+)") second)) (filter some?))')
        COMPREPLY=($(compgen -W "$BB_TASKS $BB_HELP" -- "''${COMP_WORDS[$COMP_CWORD]}"))
      }
      complete -f -F _bb_complete bb # autocomplete filenames as well
    '';

    home.sessionVariables.CLJ_CONFIG = "${config.xdg.configHome}/clojure";
    xdg.configFile."clojure/deps.edn".source = ./deps.edn;
    xdg.configFile."clojure-lsp/config.edn".source = ./config.edn;
  };
}
