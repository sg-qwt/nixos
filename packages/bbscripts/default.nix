{
  lib,
  self,
  symlinkJoin,
  pkgs,
  ...
}:
let
  hosts = self.shared-data.hosts |> builtins.attrNames |> lib.concatStringsSep ":";
  bento = pkgs.writers.writeBabashkaBin "bento" {
    makeWrapperArgs = [
      "--set"
      "BABASHKA_CLASSPATH"
      "\"\""

      "--set"
      "MYOS_BENTO_HOSTS"
      "${hosts}"

      "--set"
      "MYOS_BENTO_SHI_DATA"
      "${self + "/resources/dicts/shi.txt"}"

      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [
        pkgs.brightnessctl
        pkgs.libnotify
        pkgs.asusctl
      ]}"
    ];
  } (builtins.readFile ./bento.clj);
in
symlinkJoin {
  name = "bbscripts";
  paths = [ bento ];
}
