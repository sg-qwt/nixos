s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "android" {
  programs.adb.enable = true;
  myos.user.extraGroups = [ "adbusers" ];
}
