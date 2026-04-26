{ config, lib, pkgs, self, ... }:

with lib;
let
  cfg = config.myos.clash-meta;
  host = "127.0.0.1";
  cap = [
    "CAP_NET_ADMIN"
    "CAP_NET_RAW"
    "CAP_NET_BIND_SERVICE"
    "CAP_SYS_TIME"
    "CAP_SYS_PTRACE"
    "CAP_DAC_READ_SEARCH"
    "CAP_DAC_OVERRIDE"
  ];
  inherit (self.shared-data) ports;
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
      vaultix.secrets.sing-pass = { };
      vaultix.secrets.sing-vless-uuid = { };
      vaultix.secrets.warp-key = { };
      vaultix.secrets.clash-secret = { };
      vaultix.templates.clashm = {
        content = builtins.toJSON
          (import ./clash.nix {
            inherit config pkgs self;
            interface = cfg.interface;
          });
      };

      networking.firewall.trustedInterfaces = [ cfg.interface ];

      services.mihomo = {
        enable = true;
        package = pkgs.mihomo.overrideAttrs (
          _:
          let
            rev = "82621cd1bf9bf9976f787b69e06677ce0daeb21e";
            version = "alpha-unstable-82621cd";
          in
          {
            inherit version;
            src = pkgs.fetchFromGitHub {
              owner = "MetaCubeX";
              repo = "mihomo";
              inherit rev;
              hash = "sha256-zGSbOkZ1ESYqz0R74j9dRp09cwzs8OfhQ16ukh93bi8=";
            };
            vendorHash = "sha256-ju/j08AzpejuMNngMAq81bp9ZSQgKhjxZTaACqd5OPc=";
            ldflags = [
              "-s"
              "-w"
              "-X github.com/metacubex/mihomo/constant.Version=${version}"
            ];
          }
        );
        configFile = config.vaultix.templates.clashm.path;
        webui = pkgs.metacubexd;
        tunMode = true;
      };

      systemd.services.mihomo = {
        restartTriggers = [
          config.vaultix.templates.clashm.content
        ];
        serviceConfig = {
          CapabilityBoundingSet = lib.mkForce cap;
          AmbientCapabilities = lib.mkForce cap;
          ExecStartPre = [
            "${pkgs.coreutils}/bin/ln -sf ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat /var/lib/private/mihomo/GeoIP.dat"
            "${pkgs.coreutils}/bin/ln -sf ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat /var/lib/private/mihomo/GeoSite.dat"
          ];
        };
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
    };
}
