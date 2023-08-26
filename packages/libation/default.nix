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

  #TODO add desktop item

  meta = with lib; {
    description = "Libation: Liberate your Library ";
    homepage = "https://github.com/rmcrackan/Libation";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
