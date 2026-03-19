{ lib
, stdenv
, fetchzip
, ...
}:

stdenv.mkDerivation rec {
  pname = "og-packs";
  version = "unstable-2026-03-19";
  rev = "c795d88964369d3c60a171a2d6a03cc28d4c0fd9";

  src = fetchzip {
    url = "https://github.com/PeonPing/og-packs/archive/${rev}.tar.gz";
    hash = "sha256-moJ8REUVQkAUhjUrn0ZSctoHIEtyPiMoqco4zSrsvkY=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/og-packs
    cp -r og-packs-${rev}/dota2_* og-packs-${rev}/peon $out/share/og-packs/

    runHook postInstall
  '';
}
