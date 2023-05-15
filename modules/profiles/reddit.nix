s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "reddit" (
  let
    inherit (config.myos.data) fqdn ports;
    reddit-port = ports.reddit;
    subs =
      lib.concatStringsSep "+" [
        # gaming
        "brotato" "deadcells" "DotA2" "humblebundles"
        "linux_gaming" "NewYuzuPiracy" "SwitchPirates"
        "Peglin" "Steam" "steamdeals" "SteamDeck" "TOTK"
        # tech
        "btrfs" "Clojure" "framework" "hackernews"
        "homelab" "lisp" "NixOS" "unixporn" "ProgrammerHumor"
        # emacs
        "emacs" "OrgRoam" "planetemacs"
        # crypto & finance
        "CryptoMarkets" "CryptoCurrency" "Bitcoin" "wallstreetbets"
        # misc
        "dumbclub" "real_China_irl" "saraba2nd"
        "shanghai" "unpopularopinion"
      ];
  in
  {
    services.libreddit = {
      enable = true;
      address = "127.0.0.1";
      port = reddit-port;
    };

    systemd.services.libreddit.environment = {
      LIBREDDIT_ROBOTS_DISABLE_INDEXING = "on";
      LIBREDDIT_DEFAULT_SHOW_NSFW = "on";
      LIBREDDIT_DEFAULT_USE_HLS = "on";
      LIBREDDIT_DEFAULT_SUBSCRIPTIONS = subs;
    };

    services.nginx.virtualHosts."red.${fqdn.edg}" = {
      forceSSL = true;
      useACMEHost = "edg";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString reddit-port}";
      };
    };
  }
)
