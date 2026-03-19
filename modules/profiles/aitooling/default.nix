s@{ config, pkgs, lib, self, ... }:
let
  piro = pkgs.writeScriptBin "piro" ''
    exec ${lib.getExe pkgs.llm-agents.pi} --tools read,grep,find,ls "$@"
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
          disableAutoUpdate = true;
          disableUpdateNag = true;
        };
        context = {
          fileName = [ "AGENTS.md" ];
        };
      };
    };
    home.file.".gemini/settings.json".force = true;

    home.file.".agents/skills/brepl/SKILL.md".source = pkgs.my.brepl + "/share/brepl/SKILL.md";

    home.file.".pi/agent/extensions/notify.ts".source = pkgs.replaceVars ./notify.ts {
      sound = "${pkgs.my.og-packs}/share/og-packs/dota2_axe/sounds/AxeIsReady.mp3";
    };
  };

  environment.systemPackages = with pkgs; [
    my.brepl
    llm-agents.pi
    piro
  ];


}
