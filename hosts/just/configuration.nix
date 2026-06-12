{ config, lib, pkgs, modulesPath, self, ... }:
let
  edg = self.tfo.fqdn.edg;
  cybcc = self.tfo.fqdn.cybcc;
in
{
  networking.firewall.enable = false;

  myos.tmux.enable = true;

  myos.singbox = {
    enable = true;
    profile = "hysteria";
  };

  myos.metrics = {
    enable = true;
  };

  vaultix.secrets.cloudflare-token = { };
  vaultix.templates.acme-credential.content = ''
    CF_DNS_API_TOKEN=${config.vaultix.placeholder.cloudflare-token}
  '';

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@${edg}";
  security.acme.certs."cybcc" = {
    domain = "${cybcc}";
    dnsPropagationCheck = true;
    dnsProvider = "cloudflare";
    extraDomainNames = [ "*.${cybcc}" ];
    environmentFile = config.vaultix.templates.acme-credential.path;
  };
}
