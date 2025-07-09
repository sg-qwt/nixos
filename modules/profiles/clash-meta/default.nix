{ config, lib, pkgs, self, ... }:

with lib;
let
  cfg = config.myos.clash-meta;
  host = "127.0.0.1";
  inherit (config.myos.data) ports;
in
{
  options.myos.clash-meta = {
    enable = mkEnableOption "clash meta";
    interface = mkOption {
      type = types.str;
      default = "mihomo0";
    };
  };

  config = mkIf cfg.enable
    {
      vaultix.secrets.sspass = { };
      vaultix.secrets.sing-shadow = { };
      vaultix.secrets.sing-shadow-tls = { };
      vaultix.secrets.sing-vless-uuid = { };
      vaultix.secrets.warp-key = { };
      vaultix.secrets.clash-secret = { };
      vaultix.secrets.dui-ipv4 = { };
      vaultix.secrets.xun-ipv4 = { };
      vaultix.templates.clashm = {
        content = lib.generators.toYAML { }
          (import ./clash.nix {
            inherit config pkgs;
            interface = cfg.interface;
          });
      };

      networking.firewall.trustedInterfaces = [ cfg.interface ];

      services.mihomo = {
        enable = true;
        configFile = config.vaultix.templates.clashm.path;
        webui = pkgs.metacubexd;
        tunMode = true;
      };

      systemd.services.mihomo = {
        restartTriggers = [
          config.vaultix.templates.clashm.content
        ];
        serviceConfig.ExecStartPre = [
          "${pkgs.coreutils}/bin/ln -sf ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat /var/lib/private/mihomo/GeoIP.dat"
          "${pkgs.coreutils}/bin/ln -sf ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat /var/lib/private/mihomo/GeoSite.dat"
        ];
      };


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

      myhome = {

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
