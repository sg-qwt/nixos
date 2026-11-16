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
  version = "0.65.0-unstable-2026-11-14";
  # The pinned Elisp remains compatible with the 0.65.0 release module.
  moduleVersion = "0.65.0";
  ghostelModule = fetchurl {
    url = "https://github.com/dakra/ghostel/releases/download/v${moduleVersion}/ghostel-module-x86_64-linux.so";
    hash = "sha256-1ZKgb/xS6N51aG0f/KKRyRR0arXq38WsukuPOPevhbc=";
  };
in
emacsPackages.melpaBuild {
  pname = "ghostel";
  inherit version;

  src = fetchFromGitHub {
    owner = "dakra";
    repo = "ghostel";
    rev = "98be9d95ecad8135a160696980338c9e2cc24fdb";
    hash = "sha256-BPUrfwgzUlSrblGkDB1ajbAoeGvvtE0E+F+AP7zyjzM=";
  };

  packageRequires = [ emacsPackages.compat ];
  files = ''("lisp/*.el" "etc" "ghostel-module.so" "ghostel-module.version")'';

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.libc ];

  preBuild = ''
    install -m755 ${ghostelModule} ghostel-module.so
    printf '%s\n' '${moduleVersion}' > ghostel-module.version
  '';

  postInstall = ''
    ln -s "emacs/site-lisp/elpa/$ename-$melpaVersion/etc" "$out/share/ghostel"
  '';

  passthru = { inherit ghostelModule; };

  meta = {
    description = "Emacs terminal emulator powered by libghostty, with a prebuilt native module";
    homepage = "https://github.com/dakra/ghostel";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
}
