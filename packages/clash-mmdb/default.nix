{ lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "clash-mmdb";
  version = "20220812";

  src = fetchurl {
    url =
      "https://github.com/Dreamacro/maxmind-geoip/releases/download/${version}/Country.mmdb";
    sha256 = "UyoMB+oJLP0l5GeLpMsx5yjjRjTMM0WC1lokXG2Fq3U=";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    install -Dm755 $src $out/Country.mmdb
  '';

  meta = with lib; {
    description = "Maxmind GeoIP database";
    homepage = "https://github.com/Dreamacro/maxmind-geoip";
    license = licenses.unfreeRedistributable;
    platforms = platforms.all;
  };
}
