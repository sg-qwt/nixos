s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "miniflux" (
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
        POLLING_FREQUENCY = "360";
      };
    };

    services.nginx.virtualHosts."${fqdn.edg}".locations = {
      "${path.miniflux}" = {
        proxyPass = "http://localhost:${toString ports.miniflux}";
      };
    };

    systemd.services.rsshub = {
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${pkgs.my.rsshub}/bin/rsshub
      '';

      environment = {
        NO_LOGFILES = "true";
        PORT = "${toString ports.rsshub}";
      };

      serviceConfig = {
        Restart = "on-failure";
        DynamicUser = true;
      };
    };
  }
)
