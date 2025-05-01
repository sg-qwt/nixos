{ config }:
let
  server = config.myos.singbox.sni;
  inherit (config.myos.data) ports;
in
{
  log = {
    level = "warn";
  };
  inbounds = [
    {
      type = "vless";
      tag = "vless-in";
      listen = "::";
      listen_port = ports.reality;
      users = [
        {
          uuid = config.vaultix.placeholder.sing-vless-uuid;
          flow = "xtls-rprx-vision";
        }
      ];
      tls = {
        enabled = true;
        server_name = server;
        reality = {
          enabled = true;
          handshake = {
            server = server;
            server_port = ports.https;
          };
          private_key = config.vaultix.placeholder.sing-reality-private;
          short_id = [
            "fdb1"
          ];
        };
      };
    }
  ];
}
