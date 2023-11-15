{ pkgs, writeShellApplication, ... }:
{ name, source, deps ? [ ], args ? [ ] }:
writeShellApplication {
  inherit name;
  runtimeInputs = deps;
  text = ''
    ${pkgs.my.babashka-bin}/bin/bb ${source} ${toString args} "$@"
  '';
}
