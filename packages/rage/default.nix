{ lib, symlinkJoin, pkgs, ... }:
let
  deps = with pkgs; [ age-plugin-yubikey ];
in
symlinkJoin {
  name = "rage";
  paths = [ pkgs.rage ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/rage \
      --set PINENTRY_PROGRAM ${lib.getExe pkgs.pinentry-qt} \
      --prefix PATH : ${lib.makeBinPath deps}
  '';
}
