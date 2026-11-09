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
  version = "0.62.0";
  ghostelModule = fetchurl {
    url = "https://github.com/dakra/ghostel/releases/download/v${version}/ghostel-module-x86_64-linux.so";
    hash = "sha256-tE9M/qdWl3mPYInUKStVqJOLWsNcV/D83gdhjXfl3lA=";
  };
in
emacsPackages.melpaBuild {
  pname = "ghostel";
  inherit version;

  src = fetchFromGitHub {
    owner = "dakra";
    repo = "ghostel";
    tag = "v${version}";
    hash = "sha256-wHpaa4c3kSiBc7RiAMUWme1q2O7+ArUy4nxjo37IrU8=";
  };

  packageRequires = [ emacsPackages.compat ];
  files = ''(:defaults "etc" "ghostel-module.so" "ghostel-module.version")'';

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
