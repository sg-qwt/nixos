{ lib
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, ffmpeg-full
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
  version = "11.0.1";

  src = fetchFromGitHub {
    owner = "rmcrackan";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-//ihWGbYgcBZrckT/y87xu21XNr9rNOuSRdqufeypj4=";
  };

  projectFile = [
    "Source/LibationAvalonia/LibationAvalonia.csproj"
    "Source/LoadByOS/LinuxConfigApp/LinuxConfigApp.csproj"
    "Source/LibationCli/LibationCli.csproj"
    "Source/HangoverAvalonia/HangoverAvalonia.csproj"
  ];

  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_7_0;

  selfContainedBuild = true;

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
    ffmpeg-full

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

  # FIXME empty appsetttings won't work, https://github.com/rmcrackan/Libation/issues/725
  # Libation seems to confuse about where to create a new appsettings
  postInstall = ''
    touch $out/lib/libation/appsettings.json
  '';

  meta = with lib; {
    description = "Libation: Liberate your Library ";
    homepage = "https://github.com/rmcrackan/Libation";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
