{ stdenv, inputs, yacd-url ? "127.0.0.1:9090" }:
stdenv.mkDerivation rec {
  pname = "yacd-meta";
  version = inputs.yacd-meta.shortRev;
  src = inputs.yacd-meta;

  prePatch =
    ''
      substituteInPlace ./index.html \
        --replace "127.0.0.1:9090" "${yacd-url}"
    '';

  installPhase = ''
    cp -r . $out
  '';
}
