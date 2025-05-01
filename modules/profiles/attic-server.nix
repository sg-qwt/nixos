s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "attic-server" (
  let
    inherit (config.myos.data) fqdn ports;
    listen-addr = "[::]:${toString ports.atticd}";
    host-addr = "attic.${fqdn.edg}";
  in
  {
    vaultix.secrets.atticd-token = { };

    vaultix.templates.atticd-credentials.content = ''
      ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64=${config.vaultix.placeholder.atticd-token}
    '';

    services.atticd = {
      enable = true;

      environmentFile = config.vaultix.templates.atticd-credentials.path;

      settings = {
        listen = listen-addr;
        allowed-hosts = [ host-addr ];
        api-endpoint = "https://${host-addr}/";
        database.url = "postgres:///atticd?host=/run/postgresql";
        chunking = {
          nar-size-threshold = 64 * 1024; # 64 KiB
          min-size = 16 * 1024; # 16 KiB
          avg-size = 64 * 1024; # 64 KiB
          max-size = 256 * 1024; # 256 KiB
        };

        compression = { type = "zstd"; };

        garbage-collection = {
          interval = "5 days";
          default-retention-period = "9 months";
        };
      };
    };

    systemd.services.atticd = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
    };

    services.postgresql = {
      ensureDatabases = [ "atticd" ];
      ensureUsers = [
        {
          name = "atticd";
          ensureDBOwnership = true;
        }
      ];
    };

    services.nginx.virtualHosts."${host-addr}" = {
      forceSSL = true;
      useACMEHost = "edg";
      locations."/" = {
        proxyPass = "http://${listen-addr}";
        extraConfig = "client_max_body_size 0;";
      };
    };
  }
)
