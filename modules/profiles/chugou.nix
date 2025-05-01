{ config, lib, inputs, self, ... }:
with lib;
let
  inherit (config.myos.data) ports fqdn;
  cfg = config.myos.chugou;
in
{
  imports = [
    inputs.chugou.nixosModules.default
  ];

  options.myos.chugou = {
    enable = mkEnableOption "chugou service";
  };

  config = mkIf cfg.enable {
    vaultix.secrets.chugou-env = { };

    services.chugou = {
      enable = true;
      webPort = ports.chugou;
      credentialsFile = config.vaultix.secrets.chugou-env.path;
    };

    services.nginx.virtualHosts."chugou.${fqdn.edg}" = {
      forceSSL = true;
      useACMEHost = "edg";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString ports.chugou}";
      };
    };
  };
}
