s@{ config, pkgs, lib, self, ... }:
with lib;
let
  inherit (config.myos.data) ports fqdn path;
  cfg = config.myos.metrics;
  chugou = {
    job_name = "chugou";
    static_configs = [
      {
        targets = [ "127.0.0.1:${toString ports.chugou-prometheus-client}" ];
      }
    ];
  };
in
{
  options.myos.metrics = {
    enable = mkEnableOption "prometheus metrics";

    chugou = mkEnableOption "chugou scrape";
  };

  config = mkIf cfg.enable {

    sops.secrets.grafana-write-token = {
      sopsFile = self + "/secrets/secrets.yaml";
      owner = config.systemd.services.prometheus.serviceConfig.User;
    };

    services.prometheus = {
      enable = true;
      port = ports.prometheus;
      retentionTime = "7d";

      globalConfig = {
        scrape_interval = "1m";
        evaluation_interval = "1m";
      };

      exporters.node = {
        enable = true;
        port = ports.prometheus-node-exporter;
        enabledCollectors = [
          "systemd"
        ];
      };

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString ports.prometheus-node-exporter}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ] ++ (lib.optional cfg.chugou chugou);

      remoteWrite = [
        {
          url = "https://prometheus-prod-37-prod-ap-southeast-1.grafana.net/api/prom/push";
          basic_auth = {
            username = "1195522";
            password_file = config.sops.secrets.grafana-write-token.path;
          };
        }
      ];
    };
  };
}
