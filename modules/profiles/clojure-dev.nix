s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "clojure-dev"
{
  home-manager.users."${config.myos.users.mainUser}" = {
    home.packages = with pkgs; [
      jdk11
      (clojure.override { jdk = jdk11; })
      clojure-lsp
      babashka
    ];
  };
}
