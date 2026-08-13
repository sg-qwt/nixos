s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "printing"
{
  environment.systemPackages = with pkgs; [
    orca-slicer
  ];

  myhome = {
  };
}
