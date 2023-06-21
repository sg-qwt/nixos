{ pkgs
, mytreefmt
, self
}:
pkgs.runCommandNoCC "treefmt"
{
  nativeBuildInputs = [
    mytreefmt
  ];
} ''
  # keep timestamps so that treefmt is able to detect mtime changes
  cp --no-preserve=mode --preserve=timestamps -r ${self} source
  cd source
  HOME=$TMPDIR treefmt --no-cache --fail-on-change
  touch $out
''
