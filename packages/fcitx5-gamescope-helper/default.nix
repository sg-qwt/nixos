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
  pname = "fcitx5-gamescope-helper";
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
    install -Dm644 helper.py "$out/libexec/fcitx5-gamescope-helper.py"
    makeWrapper ${python}/bin/python3 "$out/bin/fcitx5-gamescope-helper" \
      --add-flags "$out/libexec/fcitx5-gamescope-helper.py" \
      --prefix PATH : ${lib.makeBinPath [ fcitx5 ]}
    runHook postInstall
  '';

  meta = {
    description = "Connect Fcitx to Gamescope displays and associate its candidate popups with games";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "fcitx5-gamescope-helper";
  };
}
