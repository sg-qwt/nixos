{
  pkgs,
  lib,
  symlinkJoin,
  makeWrapper,
  inputs,
  ...
}:
let
  extensions = [
    pkgs.my.pi-codex-usage
    pkgs.my.pi-notify
    (pkgs.atuin.src + "/contrib/pi/atuin.ts")
  ];
  skills = [
    (pkgs.my.brepl + "/share/brepl/SKILL.md")
  ];
  wrapperFlags = [
    "--set PI_TELEMETRY 0"
    "--prefix PATH : ${lib.makeBinPath [ pkgs.atuin ]}"
  ]
  ++ map (
    extension: "--add-flags ${lib.escapeShellArg "--extension ${toString extension}"}"
  ) extensions
  ++ map (skill: "--add-flags ${lib.escapeShellArg "--skill ${toString skill}"}") skills;
  pi = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
in
symlinkJoin {
  name = "pi";
  inherit (pi) version;
  paths = [
    pi
    pkgs.my.brepl
  ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/pi ${lib.concatStringsSep " " wrapperFlags}
  '';
  meta = (pi.meta or { }) // {
    description = "pi wrapped with preloaded extensions and skills";
    mainProgram = "pi";
  };
}
