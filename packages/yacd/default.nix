{ inputs, lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "yacd";
  version = "0.3.6";
  src = inputs.yacd;

  installPhase = ''
    cp -r . $out
  '';

  meta = with lib; {
    homepage = "https://github.com/haishanh/yacd";
    description = "Yet Another Clash Dashboard";
    license = licenses.mit;
  };
}
