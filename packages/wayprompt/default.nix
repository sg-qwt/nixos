{ lib
, stdenv
, fetchFromSourcehut
, fcft
, libxkbcommon
, pkg-config
, pixman
, scdoc
, wayland
, wayland-protocols
, zig_0_10
, ...
}:

let rev = "a36891ed77b68a4c317361a622c9928be4b9bdbc"; in
stdenv.mkDerivation {
  pname = "wayprompt-unstable";
  version = rev;

  src = fetchFromSourcehut {
    owner = "~leon_plickat";
    repo = "wayprompt";
    rev = rev;
    hash = "sha256-tdXW40SLSDGrHxOvHz3cY7VXLmbcQUR+Dmq//bw4V7I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    zig_0_10
    pkg-config
    scdoc
    wayland
    # wayland-scanner
  ];
  buildInputs = [
    fcft
    libxkbcommon
    pixman
    wayland-protocols
  ];

  # Builds and installs (at the same time) with Zig.
  dontConfigure = true;
  # dontBuild = true;

  # Give Zig a directory for intermediate work.
  preInstall = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    runHook preInstall
    zig build -Drelease-safe -Dcpu=baseline --prefix $out install
    ln -s "$out/bin/wayprompt" "$out/bin/hiprompt-wayprompt"
    ln -s "$out/bin/wayprompt" "$out/bin/wayprompt-cli"
    runHook postInstall
  '';

  installFlags = [ "DESTDIR=$(out)" ];

  meta = with lib; {
    homepage = "https://git.sr.ht/~leon_plickat/wayprompt";
    description = "multi-purpose prompt tool for Wayland";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
  };
}
