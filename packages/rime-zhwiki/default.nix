{ stdenvNoCC
, lib
, fetchurl
, ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "rime-zhwiki";

  version = "20220722";

  src = fetchurl {
    url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.4/zhwiki-20220722.dict.yaml";
    sha256 = "sha256-swROyS8iqbgkdxhvv/+a9v8r3xgBIWO2LC7pmfRTxcY=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/rime-data
    cp ${src} $out/share/rime-data/zhwiki.dict.yaml
  '';

  meta = with lib; {
    description = "Fcitx 5 Pinyin Dictionary from zh.wikipedia.org";
    homepage = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki";
    license = licenses.unlicense;
  };
}
