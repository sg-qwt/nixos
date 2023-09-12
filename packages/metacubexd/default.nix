{ stdenv, nvsource, ... }:
stdenv.mkDerivation {
  inherit (nvsource) pname version src;

  installPhase = ''
    cp -r . $out
  '';
}
