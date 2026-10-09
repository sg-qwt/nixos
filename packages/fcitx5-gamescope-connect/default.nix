{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
  fcitx5,
  ...
}:
let
  python = python3.withPackages (ps: [ ps.python-xlib ]);
in
stdenvNoCC.mkDerivation {
  pname = "fcitx5-gamescope-connect";
  version = "0.1.1";
  src = ./.;

  nativeBuildInputs = [
    python
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm644 connect.py "$out/libexec/fcitx5-gamescope-connect.py"
    makeWrapper ${python}/bin/python3 "$out/bin/fcitx5-gamescope-connect" \
      --add-flags "-B $out/libexec/fcitx5-gamescope-connect.py" \
      --prefix PATH : ${lib.makeBinPath [ fcitx5 ]}
    runHook postInstall
  '';

  meta = {
    description = "Configure Gamescope display DPI and register its Xwayland displays with Fcitx at launch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "fcitx5-gamescope-connect";
  };
}
