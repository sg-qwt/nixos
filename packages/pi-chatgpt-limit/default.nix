{ lib
, stdenvNoCC
, fetchFromGitHub
, ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "pi-chatgpt-limit";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "patlux";
    repo = "pi-chatgpt-limit";
    rev = "450d931b8f6c468c7772271336d68d2b1923dc2a";
    hash = "sha256-6k2vKskJmwyuw9uSn1oDXkiZymJUZqW0ylJnyQ27joA=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 index.js package.json README.md LICENSE -t $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "Pi extension that shows ChatGPT Codex subscription usage in the footer";
    homepage = "https://github.com/patlux/pi-chatgpt-limit";
    license = licenses.mit;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
