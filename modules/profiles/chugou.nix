{ config, lib, inputs, self, ... }:
with lib;
let
  inherit (config.myos.data) ports;
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
    sops.secrets.chugou-env = {
      sopsFile = self + "/secrets/chugou.yaml";
      restartUnits = [ "chugou.service" ];
    };

    services.chugou = {
      enable = true;
      webPort = ports.chugou;
      credentialsFile = config.sops.secrets.chugou-env.path;
    };
  };
}
