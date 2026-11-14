{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  emacsPackages,
  ...
}:
let
  version = "0.65.0";
  ghostelModule = fetchurl {
    url = "https://github.com/dakra/ghostel/releases/download/v${version}/ghostel-module-x86_64-linux.so";
    hash = "sha256-1ZKgb/xS6N51aG0f/KKRyRR0arXq38WsukuPOPevhbc=";
  };
in
emacsPackages.melpaBuild {
  pname = "ghostel";
  inherit version;

  src = fetchFromGitHub {
    owner = "dakra";
    repo = "ghostel";
    tag = "v${version}";
    hash = "sha256-Y+0P6ELzaMgOxNivUPKUzQ4H7Mk2d4a5pVfE2D2202s=";
  };

  packageRequires = [ emacsPackages.compat ];
  files = ''("lisp/*.el" "etc" "ghostel-module.so" "ghostel-module.version")'';

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.libc ];

  preBuild = ''
    install -m755 ${ghostelModule} ghostel-module.so
    printf '%s\n' '${version}' > ghostel-module.version
  '';

  passthru = { inherit ghostelModule; };

  meta = {
    description = "Emacs terminal emulator powered by libghostty, with a prebuilt native module";
    homepage = "https://github.com/dakra/ghostel";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
}
