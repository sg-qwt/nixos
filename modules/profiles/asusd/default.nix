s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "asusd"
{
  services = {
    power-profiles-daemon.enable = true;
    asusd = {
      enable = true;
      asusdConfig.source = ./asusd.ron;
      auraConfigs."19b6".source = ./aura_19b6.ron;
      fanCurvesConfig.source = ./fan_curves.ron;
    };
  };
}
