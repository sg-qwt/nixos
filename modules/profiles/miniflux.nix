s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "miniflux" (
  let
    inherit (config.myos.data) fqdn ports path;
  in
  {
    sops.secrets.miniflux-admin = {
      sopsFile = self + "/secrets/secrets.yaml";
      restartUnits = [ "miniflux.service" ];
    };

    services.miniflux = {
      enable = true;
      adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
      config = {
        LISTEN_ADDR = ":${toString ports.miniflux}";
        BASE_URL = "https://${fqdn.edg}${path.miniflux}";
      };
    };

    services.nginx.virtualHosts."${fqdn.edg}".locations = {
      "${path.miniflux}" = {
        proxyPass = "http://localhost:${toString ports.miniflux}";
      };
    };
  }
)
