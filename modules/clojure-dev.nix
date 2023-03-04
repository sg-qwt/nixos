{ config, pkgs, lib, helpers, ... }:
helpers.mkModule config lib
  "clojure-dev"
  "clojure dev tools"
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
