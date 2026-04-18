{ lib
, stdenvNoCC
, fetchFromGitHub
, fetchurl
, gnutar
, gzip
, ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "pi-clojure";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "markokocic";
    repo = "pi-clojure";
    rev = "f9185a93595ed8809e76d8a9c1bf876f4d4475b5";
    hash = "sha256-hyzuqNfduDQ1ul+mFvS/gAdAwj4vHoIYeQrdbsxnPOQ=";
  };

  bencodeTgz = fetchurl {
    url = "https://registry.npmjs.org/bencode/-/bencode-4.0.0.tgz";
    hash = "sha256-LbCJfXYcl84zZ6ZcFbRsYIBUY06naqrkf89UTHGF1Wk=";
  };

  uint8UtilTgz = fetchurl {
    url = "https://registry.npmjs.org/uint8-util/-/uint8-util-2.2.5.tgz";
    hash = "sha256-1lfSwTaOOpWAYn/jUbFox6yYK58ypxg63KfzfGvDMuU=";
  };

  base64ArraybufferTgz = fetchurl {
    url = "https://registry.npmjs.org/base64-arraybuffer/-/base64-arraybuffer-1.0.2.tgz";
    hash = "sha256-4fdEi8uEjkc4LK/FK+4OuDl4ISzsykzhL4oAvNeHRyM=";
  };

  parinferTgz = fetchurl {
    url = "https://registry.npmjs.org/parinfer/-/parinfer-3.13.1.tgz";
    hash = "sha256-c8KPMs2QqGijtnBcT/UBUPTqwEsBCujk5WG4GGdcrn0=";
  };

  nativeBuildInputs = [ gnutar gzip ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./. $out/
    chmod -R u+w $out

    mkdir -p $out/node_modules/bencode
    mkdir -p $out/node_modules/uint8-util
    mkdir -p $out/node_modules/base64-arraybuffer
    mkdir -p $out/node_modules/parinfer

    tar -xzf $bencodeTgz --strip-components=1 -C $out/node_modules/bencode
    tar -xzf $uint8UtilTgz --strip-components=1 -C $out/node_modules/uint8-util
    tar -xzf $base64ArraybufferTgz --strip-components=1 -C $out/node_modules/base64-arraybuffer
    tar -xzf $parinferTgz --strip-components=1 -C $out/node_modules/parinfer

    runHook postInstall
  '';

  meta = with lib; {
    description = "pi package for Clojure development via nREPL";
    homepage = "https://github.com/markokocic/pi-clojure";
    license = licenses.epl20;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
