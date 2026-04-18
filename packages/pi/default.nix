{ pkgs, lib, symlinkJoin, makeWrapper, ... }:
let
  extensions = [
    pkgs.my.pi-clojure
    pkgs.my.pi-notify
  ];
  skills = [
    (pkgs.my.brepl + "/share/brepl/SKILL.md")
  ];
  wrapperFlags =
    [ "--set PI_TELEMETRY 0" ]
    ++ map (extension: "--add-flags ${lib.escapeShellArg "--extension ${toString extension}"}") extensions
    ++ map (skill: "--add-flags ${lib.escapeShellArg "--skill ${toString skill}"}") skills;
in
symlinkJoin {
  name = "pi";
  paths = [
    pkgs.llm-agents.pi
    pkgs.my.brepl
  ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/pi ${lib.concatStringsSep " " wrapperFlags}
  '';
  meta = (pkgs.llm-agents.pi.meta or { }) // {
    description = "pi wrapped with preloaded extensions and skills";
    mainProgram = "pi";
  };
}
