s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "android" {
  myhome = {
    home.packages = with pkgs; [
      android-tools
      scrcpy
    ];
    programs.bash.shellAliases = {
      scr = "scrcpy --no-audio --stay-awake --video-codec=h265";
    };
  };
}
