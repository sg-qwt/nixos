{ config, self }:
let
  server = config.myos.singbox.sni;
  inherit (self.shared-data) ports;
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
          uuid._secret = config.vaultix.secrets.sing-vless-uuid.path;
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
          private_key._secret = config.vaultix.secrets.sing-reality-private.path;
          short_id = [
            "fdb1"
          ];
        };
      };
    }
  ];
}
