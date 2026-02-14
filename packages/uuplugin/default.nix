{ stdenv , fetchurl , ... }:

stdenv.mkDerivation rec {
  pname = "uuplugin";
  version = "11.0.14";

  src = fetchurl {
    url = "https://uurouter.gdl04.netease.com/uuplugin/steam-deck-plugin-x86_64/v${version}/uu.tar.gz";
    sha256 = "Nz+UDBI80YAKm2o9mFWGrThdwTyL0RDLv/+YPQHGgUI=";
  };

  unpackPhase = ''
    tar xf $src
  '';

  installPhase = ''
    install -Dm755 uuplugin $out/bin/uuplugin
    install -Dm644 uu.conf $out/share/uuplugin/uu.conf
  '';

  meta = {
    description = "uuplugin";
    platforms = [ "x86_64-linux" ];
    mainProgram = "uuplugin";
  };
}
