s@{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  jdk = pkgs.jdk25_headless;
in
lib.mkProfile s "clojure-dev" {
  programs.java = {
    enable = true;
    package = jdk;
  };

  myhome = { config, ... }: {
    home.packages = with pkgs; [
      (clojure.override { inherit jdk; })
      babashka-unwrapped
      neil
      cljfmt
    ];

    home.sessionVariables.CLJ_CONFIG = "${config.xdg.configHome}/clojure";
    xdg.configFile."clojure/deps.edn".source = ./deps.edn;
    xdg.configFile."clojure-lsp/config.edn".source = ./config.edn;
    xdg.configFile."nrepl/nrepl.edn".source = ./nrepl.edn;
  };
}
