{ config }:
let
  detour = "shadowsocks-in";
  inherit (config.myos.data) ports;
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
      password = config.sops.placeholder.sing-shadow;
    }
    {
      type = "shadowtls";
      detour = detour;
      listen = "::";
      listen_port = ports.sstls;
      version = 2;
      password = config.sops.placeholder.sing-shadow-tls;
      handshake = {
        server = "www.microsoft.com";
        server_port = 443;
      };
    }
  ];
}
