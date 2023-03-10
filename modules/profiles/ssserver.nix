s@{ config, pkgs, lib, helpers, rootPath, ... }:
helpers.mkProfile s "ssserver"
{
  sops.secrets.sspass = {
    sopsFile = rootPath + "/secrets/secrets.yaml";
    restartUnits = [ "shadowsocks-libev.service" ];
  };

  services.shadowsocks = {
    enable = true;
    port = 3737;
    fastOpen = false;
    passwordFile = config.sops.secrets.sspass.path;
  };
}
