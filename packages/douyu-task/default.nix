{ fetchFromGitHub, buildGoModule, ... }:

let version = "v3.0.0"; in
buildGoModule {
  pname = "douyu-task";
  version = version;
  src = fetchFromGitHub {
    owner = "starudream";
    repo = "douyu-task";
    rev = version;
    hash = "sha256-P6L40VDBSbbG7orVstfIQQC9oXiibjjBs3LdFB3/SgQ=";
  };

  vendorSha256 = "sha256-PNM7istPAbk2xfdAWL71eAQS24TWE8gBvGufC8oHuU8=";

  doCheck = false;

  postFixup = ''
    mv $out/bin/cmd $out/bin/douyu-task
  '';
}
