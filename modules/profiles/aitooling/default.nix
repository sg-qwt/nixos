s@{ config, pkgs, lib, self, ... }:
let
  pi = pkgs.my.pi;
  piro = pkgs.writeScriptBin "piro" ''
    exec ${lib.getExe pi} --tools read,grep,find,ls "$@"
  '';
in
lib.mkProfile s "aitooling" {
  myhome = {
    home.file.".pi/agent/APPEND_SYSTEM.md" = {
      source = ./APPEND_SYSTEM.md;
      force = true;
    };

    home.file.".pi/agent/settings.json" = {
      text = builtins.toJSON {
        lastChangelogVersion = pi.version;
        defaultProvider = "openai-codex";
        defaultModel = "gpt-5.5";
        defaultThinkingLevel = "high";
        transport = "auto";
      };
      force = true;
    };
  };

  environment.systemPackages = with pkgs; [
    pi
    piro
  ];


}
