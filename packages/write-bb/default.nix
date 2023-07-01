{ babashka, writeShellApplication, ... }:
{ name, source, deps ? [ ], args ? [ ] }:
writeShellApplication {
  inherit name;
  runtimeInputs = deps;
  text = ''
    ${babashka}/bin/bb ${source} ${toString args} "$@"
  '';
}
