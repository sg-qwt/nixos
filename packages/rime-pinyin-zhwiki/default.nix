{ stdenvNoCC
, lib
, fetchurl
, ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "rime-pinyin-zhwiki";
  version = "20231016";
  src = fetchurl {
    url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.4/zhwiki-20231016.dict.yaml";
    sha256 = "sha256-6KQL7Ef+EqK5RIw2r+qox2rmyhLg07H3tiXG3GIcO8w=";
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
