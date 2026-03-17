s@{ config, pkgs, lib, self, ... }:
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
          theme = "ANSI Light";
          hideBanner = true;
          showMemoryUsage = true;
          hideContextPercentage = false;
          useFullWidth = true;
        };
        general = {
          previewFeatures = true;
          vimMode = false;
          disableAutoUpdate = true;
          disableUpdateNag = true;
        };
        context = {
          fileName = [ "AGENTS.md" ];
        };
      };
      context = {
        AGENTS = ./agents.md;
      };
    };
    home.file.".gemini/settings.json".force = true;
  };

  environment.systemPackages = with pkgs; [
    my.brepl
    llm-agents.pi
  ];
}
