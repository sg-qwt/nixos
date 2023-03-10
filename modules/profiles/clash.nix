{ config, lib, pkgs, rootPath, ... }:

with lib;

let
  cfg = config.myos.clash;
in
{
  options.myos.clash = {
    enable = mkEnableOption "clash and yacd dashboard";

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/clash";
      description = lib.mdDoc "The state directory.";
    };

    webui.enable = mkEnableOption "yacd dashboard";
  };

  config = mkIf cfg.enable
    (mkMerge [
      {
        # networking.proxy.default = "http://127.0.0.1:7890";

        sops.secrets.clash = {
          sopsFile = rootPath + "/secrets/clash.yaml.bin";
          format = "binary";
          owner = config.users.users.clash.name;
          group = config.users.users.clash.group;
          restartUnits = [ "clash.service" ];
        };

        programs.proxychains = {
          enable = true;
          chain.type = "strict";
          proxies = {
            clash = {
              enable = true;
              type = "http";
              host = "127.0.0.1";
              port = 7890;
            };
          };
        };

        users.users.clash = {
          isSystemUser = true;
          group = "clash";
          description = "Clash daemon user";
          home = cfg.stateDir;
        };
        users.groups.clash = { };

        systemd.tmpfiles.rules = [
          "d '${cfg.stateDir}' 0750 clash clash - -"
          "L+ '${cfg.stateDir}/config.yaml' - - - - ${config.sops.secrets.clash.path}"
          "L+ '${cfg.stateDir}/Country.mmdb' - - - - ${pkgs.my.clash-mmdb}/Country.mmdb"
        ];

        systemd.services.clash = {
          description = "Clash daemon service";
          after = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          script = "exec ${pkgs.clash}/bin/clash -d ${cfg.stateDir}";

          serviceConfig = {
            User = "clash";
            Restart = "on-failure";
            WorkingDirectory = cfg.stateDir;
          };
        };

        # environment.systemPackages = [
        #   (pkgs.writeShellScriptBin "enable-proxy"
        #     (import ../config/scripts/enable-proxy.nix {}))


        #   (pkgs.writeShellScriptBin "disable-proxy"
        #     (import ../config/scripts/disable-proxy.nix {}))
        # ];

      }

      (mkIf (cfg.webui.enable) {
        services.nginx.enable = true;
        services.nginx.virtualHosts.localhost = {
          root = "${pkgs.my.yacd}";
        };
      })
    ]);
}
