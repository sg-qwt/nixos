{ inputs, lib, writeText, writeScriptBin, pkgs, ... }:
let
  genfile = { dest, settings }:
    if (lib.strings.hasSuffix "yaml" (lib.strings.toLower dest)) then
      (pkgs.formats.yaml { }).generate "out.yaml" settings
    else
      writeText "out.json" (builtins.toJSON settings);

  files = (builtins.attrNames (builtins.readDir "${inputs.self}/gen"));

  scripts =
    lib.pipe files [
      (map (file: import "${inputs.self}/gen/${file}" { inherit lib; }))
      (map (aset:
        {
          dest = aset._gentarget;
          settings = (lib.filterAttrs (n: v: n != "_gentarget") aset);
        }))
      (map (aset:
        {
          outfile = genfile aset;
          dest = aset.dest;
        }))
      (map (aset:
        ''
          dest="$root/${aset.dest}"

          echo "Updating file: $dest" >&2
        
          cp -f ${aset.outfile} "$dest"
        ''
      ))
    ];
in
writeScriptBin "gen-config"
  (lib.strings.concatLines (
    [
      ''
        set -euxo pipefail
        root=$(git rev-parse --show-toplevel)
      ''
    ] ++ scripts
  ))
  
