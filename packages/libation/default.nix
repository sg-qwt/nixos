{ lib
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, libX11
, libICE
, libSM
, libXi
, libXcursor
, libXext
, libXrandr
, fontconfig
, glew
, ...
}:

buildDotnetModule rec {
  pname = "libation";
  version = "11.0.2";

  src = fetchFromGitHub {
    owner = "rmcrackan";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-dLIkcSRpTRD1OcVn3ahG3t8kmNkLWGKsSF+Mm48H0WM=";
  };

  projectFile = [
    "Source/LibationAvalonia/LibationAvalonia.csproj"
    "Source/LoadByOS/LinuxConfigApp/LinuxConfigApp.csproj"
    "Source/LibationCli/LibationCli.csproj"
    "Source/HangoverAvalonia/HangoverAvalonia.csproj"
  ];

  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.runtime_7_0;

  executables = [
    "Libation"
    "LibationCli"
  ];

  dotnetFlags = [
    "-p:Configuration=Release"
    "-p:PublishSingleFile=false"
    "-p:PublishTrimmed=false"
    "-p:Runtimeidentifier=linux-x64"
    "-p:PublishReadyToRun=false"
  ];

  runtimeDeps = [
    # Avalonia
    libX11
    libICE
    libSM
    libXi
    libXcursor
    libXext
    libXrandr
    fontconfig
    glew
  ];

  postFixup = ''
    mv $out/bin/Libation $out/bin/libation
    mv $out/bin/LibationCli $out/bin/libation-cli

    mkdir -p $out/share/{applications,icons/hicolor/scalable/apps}
    install -Dm444 $out/lib/libation/Libation.desktop $out/share/applications/Libation.desktop
    install -Dm444 $out/lib/libation/libation_glass.svg $out/share/icons/hicolor/scalable/apps/libation.svg

    substituteInPlace $out/share/applications/Libation.desktop \
      --replace "Exec=/usr/bin/libation" "Exec=libation"
  '';

  meta = with lib; {
    description = "Libation: Liberate your Library ";
    homepage = "https://github.com/rmcrackan/Libation";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
