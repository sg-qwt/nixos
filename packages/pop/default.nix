{ steam-run, makeDesktopItem, makeWrapper, fetchurl, stdenv, dpkg, ... }:
let
  pname = "pop";
  version = "8.0.20";
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchurl {
    url = "https://download.pop.com/desktop-app/linux/${version}/pop_${version}_amd64.deb";
    sha256 = "sha256-CqBOibqSvyBWvBZ4bUA73dYupeHbCufvmbLFo6lWLuk=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";

  desktopItem = makeDesktopItem {
    name = "Pop";
    exec = pname;
    comment = "Pop";
    desktopName = "Pop";
    genericName = "Pop for Linux";
    categories = [ "InstantMessaging" ];
  };

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
    cp -av usr/lib $out/

    makeWrapper ${steam-run}/bin/steam-run $out/bin/pop --add-flags $out/lib/pop/Pop
  '';

  meta = {
    description = "Pop";
    homepage = "https://pop.com";
    platforms = [ "x86_64-linux" ];
  };

}
