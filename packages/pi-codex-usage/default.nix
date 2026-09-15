{
  lib,
  stdenvNoCC,
  ...
}:

stdenvNoCC.mkDerivation {
  pname = "pi-codex-usage";
  version = "0.1.0";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 ${./codex-usage.ts} $out/extensions/codex-usage.ts

    runHook postInstall
  '';

  meta = with lib; {
    description = "Pi extension that shows ChatGPT Codex subscription usage on demand";
    platforms = platforms.all;
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
