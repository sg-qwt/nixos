{ babashka-unwrapped, writeShellApplication, ... }:
{ name, source, deps ? [ ], args ? [ ] }:
writeShellApplication {
  inherit name;
  runtimeInputs = deps;
  text = ''
    ${babashka-unwrapped}/bin/bb ${source} ${toString args} "$@"
  '';
}
