{ config, lib, pkgs, self, ... }:

with lib;
let
  cfg = config.myos.singbox;
  inherit (self.shared-data) ports;
  edgCertDir = config.security.acme.certs.edg.directory;
  cybccCertDir = config.security.acme.certs.cybcc.directory;
in
{
  options.myos.singbox = {
    enable = mkEnableOption "singbox server";
    profile = mkOption {
      type = types.enum [ "sstls" "reality" "anytls" "hysteria" ];
    };
    sni = mkOption {
      type = types.str;
      default = "www.samsung.com";
    };
    sni2 = mkOption {
      type = types.str;
      default = "cloud.tencent.com";
    };
  };

  config = mkIf cfg.enable
    {
      vaultix.secrets.sing-shadow = { };
      vaultix.secrets.sing-pass = { };
      vaultix.secrets.sing-vless-uuid = { };
      vaultix.secrets.sing-reality-private = { };
      vaultix.secrets.sing-hy = { };

      services.nginx.defaultSSLListenPort = mkIf (cfg.profile == "reality") ports.default-ssl;
      services.nginx.streamConfig = mkIf (cfg.profile == "reality") ''
        map $ssl_preread_server_name $sni_upstream {
          ${cfg.sni} singbox;
          default [::1]:${toString ports.default-ssl};
        }
        upstream singbox {
          server [::]:${toString ports.reality};
        }
        server {
          listen 0.0.0.0:${toString ports.https};
          listen [::]:${toString ports.https};
          proxy_pass $sni_upstream;
          ssl_preread on;
        }
      '';

      security.acme.certs.edg = mkIf (cfg.profile == "anytls") {
        reloadServices = [ "sing-box.service" ];
        postRun = "${lib.getExe' pkgs.acl "setfacl"} --recursive --modify u:sing-box:rX ${
          edgCertDir
        }";
      };

      security.acme.certs.cybcc = mkIf (cfg.profile == "hysteria") {
        reloadServices = [ "sing-box.service" ];
        postRun = "${lib.getExe' pkgs.acl "setfacl"} --recursive --modify u:sing-box:rX ${
          cybccCertDir
        }";
      };

      services.sing-box = {
        enable = true;
        settings = (import (./. + "/${toString cfg.profile}.nix") { inherit config self; });
      };
    };
}
