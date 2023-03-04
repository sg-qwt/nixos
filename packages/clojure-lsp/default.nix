{ pkgs, stdenv, fetchurl, jdk11, makeWrapper, ... }:
stdenv.mkDerivation rec {

  name = "clojure-lsp";
  ver = "2021.06.24-14.24.11";

  src = fetchurl {
    url = "https://github.com/clojure-lsp/clojure-lsp/releases/download/${ver}/clojure-lsp.jar";
    sha256 = "0w4wbfg8vd27j2mkqdn8pmqpndajywg3kkk3y227c319h8z418ly";
  };
  buildInputs = [ makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share
    cp $src $out/share/clojure-lsp.jar
    makeWrapper ${jdk11}/bin/java $out/bin/${name} \
      --add-flags "-Xmx4g" \
      --add-flags "-server" \
      --add-flags "-jar $out/share/${name}.jar"
  '';
}
