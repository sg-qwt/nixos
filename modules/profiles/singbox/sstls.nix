{ config, self }:
let
  detour = "shadowsocks-in";
  inherit (self.shared-data) ports;
in
{
  log = {
    level = "warn";
  };
  inbounds = [
    {
      type = "shadowsocks";
      tag = detour;
      listen = "127.0.0.1";
      network = "tcp";
      method = "2022-blake3-aes-128-gcm";
      password = config.vaultix.placeholder.sing-shadow;
    }
    {
      type = "shadowtls";
      detour = detour;
      listen = "::";
      listen_port = ports.sstls;
      version = 3;
      users = [
        {
          name = "sstls";
          password = config.vaultix.placeholder.sing-shadow-tls;
        }
      ];
      handshake = {
        server = config.myos.singbox.sni2;
        server_port = 443;
      };
      wildcard_sni = "authed";
    }
  ];
}
