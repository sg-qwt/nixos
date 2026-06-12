{ config, self }:
let
  certDir = config.security.acme.certs.cybcc.directory;
  inherit (self.shared-data) ports;
  inherit (self.tfo) fqdn;
in
{
  log = {
    level = "warn";
  };
  inbounds = [
    {
      type = "hysteria2";
      tag = "hy2-in";
      up_mbps = 10;
      down_mbps = 10;
      listen = "::";
      listen_port = ports.https;
      obfs = {
        type = "salamander";
        password._secret = config.vaultix.secrets.sing-hy.path;
      };

      users = [
        {
          name = "hysing";
          password._secret = config.vaultix.secrets.sing-hy.path;
        }
      ];

      tls = {
        enabled = true;
        server_name = fqdn.cybcc;
        alpn = [ "h3" ];
        certificate_path = "${certDir}/fullchain.pem";
        key_path = "${certDir}/key.pem";
      };
    }
  ];
}
