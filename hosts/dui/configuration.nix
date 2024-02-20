{ config, lib, pkgs, modulesPath, self, ... }:
let edg = config.myos.data.fqdn.edg; in
{
  networking.firewall.enable = false;

  myos.tmux.enable = true;

  myos.singbox = {
    enable = true;
    profile = "reality";
  };

  myos.matrix = {
    enable = true;
    chatgpt-bot = false;
    slack-bot = false;
    sliding-sync = false;
  };

  myos.metrics = {
    enable = true;
  };

  myos.attic-server.enable = true;
  myos.miniflux.enable = true;
  myos.transmission.enable = true;
  myos.dygift.enable = true;

  myos.chugou.enable = true;

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

  sops.secrets.letter = {
    sopsFile = self + "/secrets/temp.yaml";
    path = "/var/www/letter/index.html";
    owner = "nginx";
    group = "nginx";
  };
  sops.secrets.letter-pass = {
    sopsFile = self + "/secrets/temp.yaml";
    mode = "0444";
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "letter.${edg}" = {
        forceSSL = true;
        useACMEHost = "edg";
        locations."/" = {

          root = "/var/www/letter";

          extraConfig = ''
            auth_basic "my dear secret";
            auth_basic_user_file ${config.sops.secrets.letter-pass.path};
            disable_symlinks off;
          '';
        };
      };

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
