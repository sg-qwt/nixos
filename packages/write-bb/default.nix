{ pkgs, writeShellApplication, symlinkJoin, stdenv, ... }:
{ name, source, deps ? [ ], pre ? "" }:
writeShellApplication {
  inherit name;
  runtimeInputs = deps;
  text = ''
    ${pre}
    ${pkgs.my.babashka-bin}/bin/bb ${source} "$@"
  '';
}
