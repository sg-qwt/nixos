s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "clojure-dev"
{
  home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
    home.packages = with pkgs; [
      jdk11
      (clojure.override { jdk = jdk11; })
      clojure-lsp
      babashka
    ];

    programs.bash.bashrcExtra = ''
      _bb_complete() {
        BB_TASKS=$(bb tasks|bb -io '(->> *input* (drop 2) (map #(-> % (str/split #" ") first)))')
        BB_HELP=$(bb help|bb -io '(->> *input* (map #(->> % (re-find #"^  ([-a-z]+)") second)) (filter some?))')
        COMPREPLY=($(compgen -W "$BB_TASKS $BB_HELP" -- "''${COMP_WORDS[$COMP_CWORD]}"))
      }
      complete -f -F _bb_complete bb # autocomplete filenames as well
    '';

    # FIXME https://ask.clojure.org/index.php/12911/proper-xdg-support
    home.sessionVariables.CLJ_CONFIG = "${config.xdg.configHome}/clojure";
    xdg.configFile."clojure/deps.edn".source = (self + "/config/clojure/deps.edn");

  };
}
