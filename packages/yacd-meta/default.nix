{ stdenv, inputs, nvsource, yacd-url ? "127.0.0.1:9090", ... }:
stdenv.mkDerivation rec {
  inherit (nvsource) pname version src;

  prePatch =
    ''
      substituteInPlace ./index.html \
        --replace "127.0.0.1:9090" "${yacd-url}"
    '';

  installPhase = ''
    cp -r . $out
  '';
}
