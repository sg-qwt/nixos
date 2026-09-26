{
  lib,
  writeText,
  writeShellScriptBin,
  pkgs,
  self,
  ...
}:
let
  genfile =
    { dest, settings }:
    if dest |> lib.strings.toLower |> lib.strings.hasSuffix "yaml" then
      (pkgs.formats.yaml { }).generate "out.yaml" settings
    else
      settings |> builtins.toJSON |> writeText "out.json";

  files = "${self}/gen" |> builtins.readDir |> builtins.attrNames;

  scripts =
    files
    |> map (file: import "${self}/gen/${file}" { inherit lib self; })
    |> map (aset: {
      dest = aset._gentarget;
      settings = aset |> lib.filterAttrs (n: v: n != "_gentarget");
    })
    |> map (aset: {
      outfile = genfile aset;
      dest = aset.dest;
    })
    |> map (aset: ''
      dest="$root/${aset.dest}"

      echo "Updating file: $dest" >&2

      cp -f ${aset.outfile} "$dest"
    '');
in
[
  ''
    set -euxo pipefail
    root=$(git rev-parse --show-toplevel)
  ''
]
++ scripts
|> lib.strings.concatLines
|> writeShellScriptBin "gen-config"
