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
  version = "0.66.0";
  ghostelModule = fetchurl {
    url = "https://github.com/dakra/ghostel/releases/download/v${version}/ghostel-module-x86_64-linux.so";
    hash = "sha256-niPob03NXkE5ylWuS6iHLQTK2m4NFNUFCm4quUgMJ1Q=";
  };
in
emacsPackages.melpaBuild {
  pname = "ghostel";
  inherit version;

  src = fetchFromGitHub {
    owner = "dakra";
    repo = "ghostel";
    tag = "v${version}";
    hash = "sha256-0uYcK7qij6gOANQEPt3PQlCFwTFLnm4QENPa+JhxU3E=";
  };

  packageRequires = [ emacsPackages.compat ];
  files = ''("lisp/*.el" "etc" "ghostel-module.so" "ghostel-module.version")'';

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.libc ];

  preBuild = ''
    install -m755 ${ghostelModule} ghostel-module.so
    printf '%s\n' '${version}' > ghostel-module.version
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
