{ lib, fetchFromGitHub, buildGoModule, olm, ... }:

let version = "v2.0.5"; in
buildGoModule {
  pname = "douyu-task";
  version = version;
  src = fetchFromGitHub {
    owner = "starudream";
    repo = "douyu-task";
    rev = version;
    hash = "sha256-ir3SuByI2WRJ0bF15UrXHzt7nU9jkKJV5wuaAUl2EuM=";
  };

  vendorSha256 = "sha256-dXEWi7/Tv5xTB4bRo1quAFs36l2WvSepKVS/X1PK1OM=";

  doCheck = false;

  postFixup = ''
    mv $out/bin/cmd $out/bin/douyu-task
  '';
}
