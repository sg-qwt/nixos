{ stdenv, lib, nvsource, fetchurl, ... }:

stdenv.mkDerivation rec {
  inherit (nvsource) pname version src;

  buildCommand = ''
    mkdir -p $out
    tar -C $out --strip=1 -x -f $src
  '';
}
