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
      proxy_protocol = false;
      # proxy_protocol_accept_no_header = true;
      users = [
        {
          uuid = config.sops.placeholder.sing-vless-uuid;
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
          private_key = config.sops.placeholder.sing-reality-private;
          short_id = [
            "fdb1"
          ];
        };
      };
    }
  ];
}
