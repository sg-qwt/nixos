{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule rec {
  pname = "115driver";
  version = "1.3.5-unstable-2026-09-14";

  src = fetchFromGitHub {
    owner = "SheltonZhu";
    repo = "115driver";
    rev = "542720cb0034954750454e89f32b4852add6e2a9";
    hash = "sha256-AWxcsbIGC6MkXCiY5bXZxFWyacrFIX10dZ4t3NROiEU=";
  };

  vendorHash = "sha256-2XBw11wjNG1tIXVzKYOCjWffkbdAWZvMojQVgfYKm50=";

  subPackages = [ "cmd/115driver" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/SheltonZhu/115driver/cli/cmd.version=${version}"
  ];

  meta = {
    description = "CLI tool for 115 cloud storage";
    homepage = "https://github.com/SheltonZhu/115driver";
    license = lib.licenses.mit;
    mainProgram = "115driver";
  };
}
