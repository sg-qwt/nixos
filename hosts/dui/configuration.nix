{ config, lib, pkgs, modulesPath, self, ... }:
let edg = config.myos.data.fqdn.edg; in
{
  imports = [
    ../../modules/mixins/azurebase.nix
  ];

  networking.firewall.enable = false;

  myos.common.enable = true;
  myos.users.enable = true;
  myos.tmux.enable = true;

  myos.singbox = {
    enable = true;
    profile = "reality";
  };
  myos.matrix = {
    enable = true;
    chatgpt-bot = true;
    slack-bot = true;
  };
  myos.reddit.enable = true;
  myos.attic-server.enable = true;
  myos.miniflux.enable = true;

  sops.secrets.cloudflare_token = {
    sopsFile = self + "/secrets/tfout.json";
  };
  sops.templates.acme-credential.content = ''
    CF_DNS_API_TOKEN=${config.sops.placeholder."cloudflare_token"}
  '';

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@${edg}";
  security.acme.certs."edg" = {
    domain = "${edg}";
    dnsPropagationCheck = true;
    dnsProvider = "cloudflare";
    extraDomainNames = [ "*.${edg}" ];
    credentialsFile = config.sops.templates.acme-credential.path;
  };
  users.users.nginx.extraGroups = [ config.users.groups.acme.name ];

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "${edg}" = {
        forceSSL = true;
        useACMEHost = "edg";

        locations."/" = {
          root = pkgs.writeTextDir "index.html" "Hello world!";
        };
      };

      "_" = {
        default = true;
        forceSSL = true;
        useACMEHost = "edg";
        locations."/" = {
          return = "404";
        };
      };
    };
  };
}
