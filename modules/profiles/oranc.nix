s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "oranc" (
  let
    inherit (config.myos.data) fqdn ports path;
  in
  {
    services.oranc = {
      enable = true;
      listen = "127.0.0.1:${toString ports.oranc}";
    };

    services.nginx.virtualHosts."ooo.${fqdn.edg}" = {
      forceSSL = true;
      useACMEHost = "edg";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString ports.oranc}";
      };
    };
  }
)
