{ config, lib, pkgs, self, ... }:

with lib;
let
  cfg = config.myos.clash-meta;
  sops-clash = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "clash-meta.service" ];
  };
  host = "127.0.0.1";
  inherit (config.myos.data) ports;
  yacd-url = "${host}:${toString ports.clash-meta-api}";
  fwmark = "0x238";
  nft-table = "clash";
  route-table = "8964";
  disable-tproxy = pkgs.writeShellApplication {
    name = "disable-tproxy";
    runtimeInputs = with pkgs; [ nftables iproute2 ];
    text = (import ./disable-tproxy.nix
      { inherit fwmark nft-table route-table; });
  };
  enable-tproxy = pkgs.writeShellApplication {
    name = "enable-tproxy";
    runtimeInputs = with pkgs; [ nftables iproute2 ];
    text = (import ./enable-tproxy.nix
      { inherit fwmark ports nft-table route-table; });
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
      sops.secrets.clash-provider-mumbai = sops-clash;
      sops.secrets.wgteam = sops-clash;
      sops.secrets.sing-shadow = sops-clash;
      sops.secrets.sing-shadow-tls = sops-clash;
      sops.secrets.sing-vless-uuid = sops-clash;
      sops.secrets.dui_ipv4 = {
        sopsFile = self + "/secrets/tfout.json";
        restartUnits = [ "clash-meta.service" ];
      };
      sops.secrets.xun_ipv4 = {
        sopsFile = self + "/secrets/tfout.json";
        restartUnits = [ "clash-meta.service" ];
      };
      sops.templates.clashm = {
        content = lib.generators.toYAML { }
          (import ./clash.nix { inherit config; });
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
        "L+ '${cfg.stateDir}/Country.mmdb' - - - - ${pkgs.dbip-country-lite}/share/dbip/dbip-country-lite.mmdb"
        "L+ '${cfg.stateDir}/GeoSite.dat' - - - - ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat"
      ];

      systemd.services.clash-meta = {
        description = "Clash Meta daemon service";
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        script = "exec ${pkgs.clash-meta}/bin/clash-meta -d ${cfg.stateDir}";
        restartTriggers = [
          config.sops.templates.clashm.content
        ];
        serviceConfig = rec {
          User = "clash-meta";
          Restart = "on-failure";
          ExecStartPre = "${disable-tproxy}/bin/disable-tproxy";
          WorkingDirectory = cfg.stateDir;
          CapabilityBoundingSet = [
            "CAP_NET_BIND_SERVICE"
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
          ];
          AmbientCapabilities = CapabilityBoundingSet;
        };
      };

      services.nginx.enable = true;
      services.nginx.virtualHosts.localhost = {
        root = "${(pkgs.my.yacd-meta.override {inherit yacd-url;})}";
      };

      environment.systemPackages = [ enable-tproxy disable-tproxy ];

      programs.proxychains = {
        enable = true;
        quietMode = true;
        proxies = {
          clash = {
            inherit host;
            enable = true;
            type = "socks5";
            port = ports.clash-meta-mixed;
          };
        };
      };

      home-manager.users."${config.myos.users.mainUser}" = {

        programs.bash.bashrcExtra = ''
          enable-proxy() {
            PROXY_HOST="localhost"
            PROXY_PORT="${toString ports.clash-meta-mixed}"

            export HTTP_PROXY="http://$PROXY_HOST:$PROXY_PORT/"
            export http_proxy="$HTTP_PROXY"

            export HTTPS_PROXY="http://$PROXY_HOST:$PROXY_PORT/"
            export https_proxy="$HTTPS_PROXY"

            export NO_PROXY="localhost, 127.0.0.0/8, ::1"
            export no_proxy="$NO_PROXY"

            echo "HTTP Proxy Enabled!"
          }

          disable-proxy() {
            unset HTTP_PROXY http_proxy
            unset HTTPS_PROXY https_proxy
            unset NO_PROXY no_proxy

            echo "HTTP Proxy Disabled!"
          }
        '';
      };
    };
}
