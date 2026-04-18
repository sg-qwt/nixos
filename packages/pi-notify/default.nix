{ lib
, stdenvNoCC
, replaceVars
, pkgs
, ...
}:

let
  sound = "${pkgs.my."og-packs"}/share/og-packs/dota2_axe/sounds/AxeIsReady.mp3";
in
stdenvNoCC.mkDerivation rec {
  pname = "pi-notify";
  version = "0.1.0";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/extensions
    install -Dm644 ${replaceVars ./notify.ts { inherit sound; }} $out/extensions/notify.ts

    runHook postInstall
  '';

  meta = with lib; {
    description = "pi extension package that plays a completion sound";
    platforms = platforms.all;
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
