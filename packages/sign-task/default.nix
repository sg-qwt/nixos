{ fetchFromGitHub, buildGoModule, ... }:

let version = "v1.0.11"; in
buildGoModule {
  pname = "sign-task";
  version = version;
  src = fetchFromGitHub {
    owner = "starudream";
    repo = "sign-task";
    rev = version;
    hash = "sha256-4wy+mnfnaAhRvw2e12G1Qqo0CZAm2RZdPkzkzf7ClC0=";
  };

  vendorHash = "sha256-bFQpKgEDlF6EL8Ube/lZH8SXsSlJkJRl2mxGKzFEFp4=";

  doCheck = false;

  postFixup = ''
    mv $out/bin/cmd $out/bin/sign-task
  '';

  meta = {
    mainProgram = "sign-task";
  };
}
