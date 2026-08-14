s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "printing"
{
  networking.firewall = {
    allowedUDPPorts = [ 2021 ];
  };

  environment.systemPackages = with pkgs; [
    filezilla
    my.orca-slicer-open
  ];

}
