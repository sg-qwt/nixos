{ config, self }:
let
  inherit (self.shared-data) ports;
  inherit (self.tfo) fqdn;
  certDir = config.security.acme.certs.edg.directory;
in
{
  log = {
    level = "warn";
  };
  inbounds = [
    {
      type = "anytls";
      tag = "anytls-in";
      listen = "::";
      listen_port = ports.anytls;
      users = [
        {
          name = "anytls";
          password._secret = config.vaultix.secrets.sing-pass.path;
        }
      ];
      tls = {
        enabled = true;
        server_name = fqdn.edg;
        alpn = ["h2"];
        certificate_path = "${certDir}/fullchain.pem";
        key_path = "${certDir}/key.pem";
      };
    }
  ];
}
