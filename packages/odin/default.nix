{
  stdenv,
  fetchzip,
  autoPatchelfHook,
  ...
}:

stdenv.mkDerivation rec {
  pname = "odin";
  version = "4";

  src = fetchzip {
    url = "https://technastic.com/wp-content/uploads/2023/06/Odin4-Linux.zip";
    hash = "sha256-DPL3hs+YLIz9V3MlJCZOF89rQATXyoQ1YoGo86AT9lc=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D odin4 $out/bin/odin
  '';
}
