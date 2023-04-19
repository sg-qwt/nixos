s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "ssserver" (with config.myos.data;
{
  sops.secrets.sspass = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "shadowsocks-libev.service" ];
  };

  sops.templates.ssserver-config.content = builtins.toJSON
    (
      let
        base-config = {
          fast_open = false;
          server = "::";
          method = "chacha20-ietf-poly1305";
          password = config.sops.placeholder.sspass;
        };
      in
      {
        servers = [
          ({
            server_port = ports.ss1;
          } // base-config)

          ({
            server_port = ports.ss2;
            plugin = "v2ray-plugin";
            plugin_opts = "server;path=${path.ss2}";
          } // base-config)
        ];
      }
    );

  services.nginx.virtualHosts."${fqdn.edg}".locations."${path.ss2}" = {
    proxyPass = "http://localhost:${toString ports.ss2}";
    proxyWebsockets = true;
  };

  systemd.services.shadowsocks-server = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ shadowsocks-rust shadowsocks-v2ray-plugin ];
    restartTriggers = [
      config.sops.templates.ssserver-config.content
    ];

    serviceConfig = {
      Restart = "always";
      LoadCredential = [
        "config:${config.sops.templates.ssserver-config.path}"
      ];
      ExecStart = "${pkgs.shadowsocks-rust}/bin/ssserver -c %d/config";
      DynamicUser = true;
    };
  };
}
)
