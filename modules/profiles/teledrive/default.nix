s@{ config, pkgs, lib, self, ... }:
let
  inherit (config.myos.data) ports fqdn;
  name = "teledrive";
  tdrive-secret = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "${name}.service" ];
  };
in
lib.mkProfile s name {
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

  sops.secrets.tdrive-api-jwt = tdrive-secret;
  sops.secrets.tdrive-file-jwt = tdrive-secret;
  sops.secrets.tdrive-api-id = tdrive-secret;
  sops.secrets.tdrive-api-hash = tdrive-secret;
  sops.secrets.tdrive-admin = tdrive-secret;

  sops.templates.tdrive-env.content = ''
    API_JWT_SECRET=${config.sops.placeholder.tdrive-api-jwt}
    FILES_JWT_SECRET=${config.sops.placeholder.tdrive-file-jwt}
    TG_API_ID=${config.sops.placeholder.tdrive-api-id}
    TG_API_HASH=${config.sops.placeholder.tdrive-api-hash}
    ADMIN_USERNAME=${config.sops.placeholder.tdrive-admin}
    DATABASE_URL=postgresql://${name}@localhost/${name}?host=/run/postgresql
    CACHE_FILES_LIMIT=20GB
    ENV=production
    PORT=${toString ports.teledrive}
    CACHE_DIR=/var/cache/${name}
  '';

  systemd.services."${name}" = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    preStart = ''
      ${pkgs.my.teledrive}/bin/teledrive-migrate-deploy
    '';
    script = ''
      ${pkgs.my.teledrive}/bin/teledrive
    '';

    restartTriggers = [
      config.sops.templates.tdrive-env.content
    ];

    serviceConfig = {
      Restart = "on-failure";
      DynamicUser = true;
      StateDirectory = name;
      CacheDirectory = name;
      EnvironmentFile = [
        config.sops.templates.tdrive-env.path
      ];
    };
  };

  services.nginx.virtualHosts."td.${fqdn.edg}" = {
    forceSSL = true;
    useACMEHost = "edg";
    extraConfig = ''
      client_header_timeout   60m;
      client_body_timeout     60m;
      client_max_body_size    2048M;
      large_client_header_buffers 8 256k;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.teledrive}";
      extraConfig = ''
        send_timeout            60m;
        proxy_buffer_size 256k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
      '';
    };
  };

}
