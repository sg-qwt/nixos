{ config, lib, pkgs, self, ... }:

with lib;
let
  cfg = config.myos.singbox;
  sops-sing = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "singbox.service" ];
  };
  cap = [
    "CAP_NET_RAW"
    "CAP_NET_ADMIN"
    "CAP_NET_BIND_SERVICE"
  ];
in
{
  options.myos.singbox = {
    enable = mkEnableOption "singbox server";
  };

  config = mkIf cfg.enable
    {
      sops.secrets.sing-shadow = sops-sing;
      sops.secrets.sing-shadow-tls = sops-sing;
      sops.templates.singbox = {
        content = builtins.toJSON
          (import (self + "/config/singbox.nix") { inherit config; });
      };

      systemd.services.singbox = {
        description = "singbox server daemon service";
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [
          config.sops.templates.singbox.content
        ];
        serviceConfig = {
          DynamicUser = true;
          StateDirectory = "singbox";
          LoadCredential = [
            "config:${config.sops.templates.singbox.path}"
          ];
          ExecStart = "${pkgs.sing-box}/bin/sing-box run -c %d/config -D $STATE_DIRECTORY";
          CapabilityBoundingSet = cap;
          AmbientCapabilities = cap;
          Restart = "on-failure";
        };
      };
    };
}
