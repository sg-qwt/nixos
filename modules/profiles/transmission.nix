s@{ config, pkgs, lib, self, ... }:
let
  inherit (self.shared-data) ports fqdn path;
in
lib.mkProfile s "transmission" {

  vaultix.secrets.trans-user = { };
  vaultix.secrets.trans-pass = { };
  vaultix.templates.transmission-credentials.content = builtins.toJSON {
    rpc-username = config.vaultix.placeholder.trans-user;
    rpc-password = config.vaultix.placeholder.trans-pass;
  };

  systemd.services.transmission.restartTriggers = [
    config.vaultix.templates.transmission-credentials.content
  ];

  services.transmission = {
    enable = true;
    webHome = pkgs.flood-for-transmission;
    credentialsFile = config.vaultix.templates.transmission-credentials.path;
    settings = {
      peer-port = ports.transmission-peer;
      rpc-port = ports.transmission;
      rpc-bind-address = "::";
      rpc-authentication-required = true;
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
      speed-limit-up-enabled = true;
      speed-limit-up = 100;
      speed-limit-down-enabled = true;
      speed-limit-down = 10000;
    };
  };

  services.nginx.virtualHosts."${fqdn.edg}".locations = {
    "${path.transmission}" = {
      proxyPass = "http://localhost:${toString ports.transmission}";
    };
  };
}
