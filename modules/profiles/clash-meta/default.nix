{
  config,
  lib,
  pkgs,
  self,
  ...
}:

with lib;
let
  yamlFormat = pkgs.formats.yaml { };
  sockFile = "/run/mihomo/mihomo.sock";
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
in
{
  options.myos.clash-meta = {
    enable = mkEnableOption "clash meta";
    interface = mkOption {
      type = types.str;
      default = "mihomo0";
    };
  };

  config = mkIf cfg.enable {
    vaultix.secrets.sspass = { };
    vaultix.secrets.sing-shadow = { };
    vaultix.secrets.sing-pass = { };
    vaultix.secrets.sing-vless-uuid = { };
    vaultix.secrets.sing-hy = { };
    vaultix.secrets.masque-key = { };
    vaultix.templates.clashm = {
      content =
        import ./clash.nix {
          inherit config pkgs self sockFile;
          interface = cfg.interface;
        }
        |> builtins.toJSON;
    };

    networking.firewall.trustedInterfaces = [ cfg.interface ];

    services.mihomo = {
      enable = true;
      package = pkgs.mihomo;
      configFile = config.vaultix.templates.clashm.path;
      webui = null;
      tunMode = true;
    };


    environment.systemPackages = with pkgs; [
      my.mihomo-tui
    ];


    users.groups.mihomo-api = { };
    myos.user.extraGroups = [ "mihomo-api" ];

    systemd.services.mihomo = {
      restartTriggers = [
        config.vaultix.templates.clashm.content
      ];
      serviceConfig = {
        Group = "mihomo-api";
        RuntimeDirectory = "mihomo";
        RuntimeDirectoryMode = "0750";
        RestrictAddressFamilies = lib.mkAfter [ "AF_UNIX" ];
        CapabilityBoundingSet = lib.mkForce cap;
        AmbientCapabilities = lib.mkForce cap;
        ExecStartPre = [
          "${pkgs.coreutils}/bin/ln -sf ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat /var/lib/private/mihomo/GeoIP.dat"
          "${pkgs.coreutils}/bin/ln -sf ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat /var/lib/private/mihomo/GeoSite.dat"
        ];
      };
    };


    myhome = { config, osConfig, ... }: {

      xdg.configFile."mihomo-tui/config.yaml" = {
        source = yamlFormat.generate "mihomo-tui-config" {
          log-level = "silent";
          mihomo-api = "unix:${sockFile}";
          ui = {
            startup-tab = "Proxies";
          };
        };
        force = true;
      };
    };
  };
}
