{ config, lib, pkgs, self, ... }:

with lib;
let
  cfg = config.myos.singbox;
  cap = [
    "CAP_NET_RAW"
    "CAP_NET_ADMIN"
    "CAP_NET_BIND_SERVICE"
  ];
  inherit (config.myos.data) ports;
in
{
  options.myos.singbox = {
    enable = mkEnableOption "singbox server";
    profile = mkOption {
      type = types.enum [ "sstls" "reality" ];
    };
    sni = mkOption {
      type = types.str;
      default = "www.samsung.com";
    };
    sni2 = mkOption {
      type = types.str;
      default = "www.bing.com";
    };
  };

  config = mkIf cfg.enable
    {
      vaultix.secrets.sing-shadow = { };
      vaultix.secrets.sing-shadow-tls = { };
      vaultix.secrets.sing-vless-uuid = { };
      vaultix.secrets.sing-reality-private = { };
      vaultix.templates.singbox = {
        content = builtins.toJSON
          (import (./. + "/${toString cfg.profile}.nix") { inherit config; });
      };

      services.nginx.defaultSSLListenPort = ports.default-ssl;
      services.nginx.streamConfig = mkIf (cfg.profile == "reality") ''
        map $ssl_preread_server_name $sni_upstream {
          ${cfg.sni} singbox;
          default [::1]:${toString ports.default-ssl};
        }
        upstream singbox {
          server [::]:${toString ports.reality};
        }
        server {
          listen 0.0.0.0:${toString ports.https};
          listen [::]:${toString ports.https};
          proxy_pass $sni_upstream;
          ssl_preread on;
        }
      '';

      systemd.services.singbox = {
        description = "singbox server daemon service";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [
          config.vaultix.templates.singbox.content
        ];
        serviceConfig = {
          DynamicUser = true;
          StateDirectory = "singbox";
          LoadCredential = [
            "config:${config.vaultix.templates.singbox.path}"
          ];
          ExecStart = "${pkgs.sing-box}/bin/sing-box run -c %d/config -D $STATE_DIRECTORY";
          CapabilityBoundingSet = cap;
          AmbientCapabilities = cap;
          Restart = "on-failure";
        };
      };
    };
}
