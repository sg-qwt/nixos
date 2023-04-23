{ stdenvNoCC
, lib
, fetchurl
, nvsource
, ...
}:

stdenvNoCC.mkDerivation rec {
  inherit (nvsource) pname version src;

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
