{ fetchFromGitHub, buildGoModule, ... }:

let version = "v3.0.2"; in
buildGoModule {
  pname = "douyu-task";
  version = version;
  src = fetchFromGitHub {
    owner = "starudream";
    repo = "douyu-task";
    rev = version;
    hash = "sha256-W3G+N5kAvueAxa6wCZ0Opjc38SpjVdV1NGaduIYONg8=";
  };

  vendorSha256 = "sha256-MI0mu/rxkrHUbgj9C5yCOcYz0A62f2MLsTk9xrtnnNI=";

  doCheck = false;

  postFixup = ''
    mv $out/bin/cmd $out/bin/douyu-task
  '';
}
