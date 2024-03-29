s@{ config, pkgs, lib, self, ... }:
let
  inherit (config.myos.data) ports fqdn path;
in
lib.mkProfile s "transmission" {

  sops.secrets.trans-user = {
    sopsFile = self + "/secrets/secrets.yaml";
  };
  sops.secrets.trans-pass = {
    sopsFile = self + "/secrets/secrets.yaml";
  };

  sops.templates.transmission-credentials.content = builtins.toJSON {
    rpc-username = config.sops.placeholder.trans-user;
    rpc-password = config.sops.placeholder.trans-pass;
  };

  systemd.services.transmission.restartTriggers = [
    config.sops.templates.transmission-credentials.content
  ];

  services.transmission = {
    enable = true;
    webHome = pkgs.flood-for-transmission;
    credentialsFile = config.sops.templates.transmission-credentials.path;
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
