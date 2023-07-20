s@{ config, pkgs, lib, self, ... }:
let
  inherit (config.myos.data) fqdn ports;
  sliding-port = ports.matrix-sliding-sync;
  name = "matrix-sliging-sync";
in
lib.mkProfile s name {
  # openssl rand -hex 32
  sops.secrets.syncv3-token = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "${name}.service" ];
  };

  sops.templates.matrix-sync-env.content = ''
    SYNCV3_SERVER=http://[::1]:${toString ports.dendrite}
    SYNCV3_DB=postgresql:///${name}?host=/run/postgresql
    SYNCV3_SECRET=${config.sops.placeholder.syncv3-token}
    SYNCV3_BINDADDR=0.0.0.0:${toString sliding-port}
  '';

  services.postgresql = {
    ensureDatabases = [ name ];
    ensureUsers = [
      {
        name = name;
        ensurePermissions = {
          "DATABASE \"${name}\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services."${name}" = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "postgresql.service" ];
    after = [ "dendrite.service" "postgresql.service" ];

    serviceConfig = {
      Restart = "on-failure";
      DynamicUser = true;
      StateDirectory = name;
      EnvironmentFile = [
        config.sops.templates.matrix-sync-env.path
      ];
    };
    script = "exec ${pkgs.matrix-sliding-sync}/bin/syncv3";
  };


  services.nginx.virtualHosts."${name}.${fqdn.edg}" = {
    forceSSL = true;
    useACMEHost = "edg";
    locations."/" = {
      proxyPass = "http://[::1]:${toString sliding-port}";
    };
  };

}
