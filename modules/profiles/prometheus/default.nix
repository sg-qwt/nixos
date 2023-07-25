s@{ config, pkgs, lib, self, ... }:
let
  inherit (config.myos.data) ports fqdn path;
in
lib.mkProfile s "prometheus" {
  services.prometheus = {
    enable = true;
    # webExternalUrl = "https://${config.networking.fqdn}/prom";
    # listenAddress = "127.0.0.1";
    port = ports.prometheus;
    retentionTime = "7d";
    globalConfig = {
      scrape_interval = "1m";
      evaluation_interval = "1m";
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "localhost:${toString ports.prometheus}" ];
          }
        ];
      }
      {
        job_name = "metrics";
        static_configs = [
          {
            targets = [ "ge.h.edgerunners.eu.org:${toString ports.telegraf-prometheus-client}" ];
          }
        ];
      }
    ];
    # rules = [
    #   (builtins.toJSON {
    #     groups = [{
    #       name = "metrics";
    #       rules = [
    #         {
    #           alert = "NodeDown";
    #           expr = "up == 0";
    #           for = "3m";
    #           annotations = {
    #             summary = "node {{ $labels.host }} down for job {{ $labels.job }}";
    #           };
    #         }
    #         {
    #           alert = "UnitFailed";
    #           expr = "systemd_units_active_code == 3";
    #           for = "1m";
    #           annotations = {
    #             summary = "unit {{ $labels.name }} on {{ $labels.host }} failed";
    #           };
    #         }
    #         {
    #           alert = "DNSError";
    #           expr = "dns_query_result_code != 0";
    #           for = "5m";
    #           annotations = {
    #             summary = "dns query for {{ $labels.domain }} IN {{ $labels.record_type }} on {{ $labels.host }} via {{ $labels.server }} failed with rcode {{ $labels.rcode }}";
    #           };
    #         }
    #         {
    #           alert = "OOM";
    #           expr = "mem_available_percent < 20";
    #           annotations = {
    #             summary = ''node {{ $labels.host }} low in memory, {{ $value | printf "%.2f" }} percent available'';
    #           };
    #         }
    #         {
    #           alert = "DiskFull";
    #           expr = "disk_used_percent { path = '/nix' } > 80";
    #           annotations = {
    #             summary = ''node {{ $labels.host }} disk full, {{ $value | printf "%.2f" }} percent used'';
    #           };
    #         }
    #       ];
    #     }];
    #   })
    # ];
    # alertmanagers = [{
    #   static_configs = [{
    #     targets = [ "127.0.0.1:8009" ];
    #   }];
    # }];
  };
}
