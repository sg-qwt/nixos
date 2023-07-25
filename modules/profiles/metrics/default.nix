s@{ config, pkgs, lib, self, ... }:
let
  inherit (config.myos.data) ports fqdn path;
in
lib.mkProfile s "metrics" {
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent.interval = "60s";
      inputs = {
        cpu = { };
        disk = { };
        diskio = { };
        mem = { };
        net = { };
        processes = { };
        system = { };
        systemd_units = { };
        dns_query = {
          servers = [
            "1.1.1.1"
            "8.8.8.8"
          ];
          domains = [ fqdn.edg ];
          record_type = "A";
          timeout = "2s";
        };
      };
      outputs = {
        prometheus_client = {
          listen = ":${toString ports.telegraf-prometheus-client}";
          metric_version = 2;
          path = path.metrics;
        };
      };
    };
  };

}
