{ stdenv, fetchFromGitHub, ... }:
stdenv.mkDerivation {
  pname = "metacubexd";
  version = "f787e4c1c1dc8ea7812858574c8df8e6ba591093";
  src = fetchFromGitHub {
    owner = "MetaCubeX";
    repo = "metacubexd";
    rev = "f787e4c1c1dc8ea7812858574c8df8e6ba591093";
    fetchSubmodules = false;
    sha256 = "sha256-sJAmereD4dGOQKCPXhSLvxAzCsG11gKLoVeJawnZnPI=";
  };

  installPhase = ''
    cp -r . $out
  '';
}
