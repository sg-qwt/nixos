{ config, lib, pkgs, rootPath, ... }:

with lib;

let
  cfg = config.myos.clash-meta;
  sops-clash = {
    sopsFile = rootPath + "/secrets/secrets.yaml";
    restartUnits = [ "clash-meta.service" ];
  };
in
{
  options.myos.clash-meta = {
    enable = mkEnableOption "clash meta";

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/clash-meta";
      description = lib.mdDoc "The state directory.";
    };
  };

  config = mkIf cfg.enable
    {
      sops.secrets.sspass = sops-clash;
      sops.secrets.clash-provider-london = sops-clash;
      sops.secrets.clash-provider-mumbai = sops-clash;
      sops.secrets.dui_ipv6 = {
        sopsFile = rootPath + "/secrets/tfout.json";
        restartUnits = [ "clash-meta.service" ];
      };
      sops.templates.clashm = {
        content = builtins.toJSON
          (import (rootPath + "/config/clash-meta/clash.nix") { inherit config; });
        owner = config.users.users.clash-meta.name;
        group = config.users.users.clash-meta.group;
      };

      users.users.clash-meta = {
        isSystemUser = true;
        group = "clash-meta";
        description = "Clash Meta daemon user";
        home = cfg.stateDir;
      };
      users.groups.clash-meta = { };

      systemd.tmpfiles.rules = [
        "d '${cfg.stateDir}' 0750 clash-meta clash-meta - -"
        "L+ '${cfg.stateDir}/config.yaml' - - - - ${config.sops.templates.clashm.path}"
        "L+ '${cfg.stateDir}/Country.mmdb' - - - - ${pkgs.clash-geoip}/etc/clash/Country.mmdb"
      ];

      systemd.services.clash-meta = {
        description = "Clash Meta daemon service";
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        script = "exec ${pkgs.clash-meta}/bin/clash-meta -d ${cfg.stateDir}";
        restartTriggers = [
          config.sops.templates.clashm.content
        ];
        serviceConfig = {
          User = "clash-meta";
          Restart = "on-failure";
          WorkingDirectory = cfg.stateDir;
        };
      };

      services.nginx.enable = true;
      services.nginx.virtualHosts.localhost = {
        root = "${pkgs.my.yacd-meta}";
      };

      programs.proxychains = {
        enable = true;
        quietMode = true;
        proxies = {
          clash = {
            enable = true;
            type = "socks5";
            host = "127.0.0.1";
            port = config.ports.clash-meta-mixed;
          };
        };
      };
    };
}
