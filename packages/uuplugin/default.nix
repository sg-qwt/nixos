{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "uuplugin";
  version = "14.11.2";

  src = fetchurl {
    url = "https://uurouter.gdl.netease.com/uuplugin/steam-deck-plugin-x86_64/v${version}/uu.tar.gz";
    hash = "sha256-oZE8mmveqVrIbvVz+ztESm1AoRS/0wnuRYdnUIs/p2I=";
  };

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 uuplugin $out/bin/uuplugin
    # uuplugin resolves ./xuplugin-guardian beside /proc/self/exe, not the cwd.
    install -Dm755 xuplugin-guardian $out/bin/xuplugin-guardian
    install -Dm644 uu.conf $out/share/uuplugin/uu.conf

    runHook postInstall
  '';

  meta = {
    description = "NetEase UU game acceleration plugin";
    homepage = "https://uu.163.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "uuplugin";
  };
}
