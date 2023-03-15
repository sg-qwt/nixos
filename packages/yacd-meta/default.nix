{ stdenv, inputs, lib }:
stdenv.mkDerivation rec {
  pname = "yacd-meta";
  version = inputs.yacd-meta.shortRev;
  src = inputs.yacd-meta;

  prePatch =
    let port = (lib.importJSON (./. + "/../../config/ports.json")).clash-meta-api; in
  ''
    substituteInPlace ./index.html \
      --replace "127.0.0.1:9090" "127.0.0.1:${toString port}"
  '';

  installPhase = ''
    cp -r . $out
  '';
}
