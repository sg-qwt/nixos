s@{ config, pkgs, lib, self, ... }:
let
  pi = pkgs.my.pi;
  piro = pkgs.writeScriptBin "piro" ''
    exec ${lib.getExe pi} --tools read,grep,find,ls "$@"
  '';
in
lib.mkProfile s "aitooling" {
  myhome = {
    programs.gemini-cli = {
      enable = true;
      package = pkgs.llm-agents.gemini-cli;
      settings = {
        privacy = {
          usageStatisticsEnabled = false;
        };
        security = {
          auth = {
            selectedType = "oauth-personal";
          };
        };
        ui = {
          theme = "ANSI";
          hideBanner = true;
          showMemoryUsage = true;
          hideContextPercentage = false;
          useFullWidth = true;
        };
        general = {
          previewFeatures = true;
          vimMode = false;
          enableAutoUpdate = false;
          enableAutoUpdateNotification = false;
        };
        context = {
          fileName = [ "AGENTS.md" ];
        };
      };
    };
    home.file.".gemini/settings.json".force = true;

    home.file.".pi/agent/APPEND_SYSTEM.md" = {
      source = ./APPEND_SYSTEM.md;
      force = true;
    };
  };

  environment.systemPackages = with pkgs; [
    pi
    piro
  ];


}
