{ lib
, symlinkJoin
, makeWrapper
, ...
}:

piPackage: extensions:
symlinkJoin {
  name = "pi-with-extensions";
  paths = [ piPackage ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/pi ${lib.concatMapStringsSep " " (extension: "--add-flags ${lib.escapeShellArg "-e ${extension}"}") extensions}
  '';
  meta = (piPackage.meta or { }) // {
    description = "pi wrapped with preloaded extensions";
    mainProgram = "pi";
  };
}
