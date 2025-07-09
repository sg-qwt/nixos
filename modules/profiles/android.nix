s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "android" {
  programs.adb.enable = true;
  myos.user.extraGroups = [ "adbusers" ];

  myhome = {
    home.packages = with pkgs; [
      scrcpy
    ];
    programs.bash.shellAliases = {
      scr = "scrcpy --no-audio --stay-awake --video-codec=h265";
    };
  };
}
