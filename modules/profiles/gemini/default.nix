s@{ config, pkgs, lib, self, ... }:
let
  inherit (self.shared-data) ports fqdn path;
in
lib.mkProfile s "gemini" {
  myhome = {
    programs.gemini-cli = {
      enable = true;
      package = pkgs.gemini-cli-bin;
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
  ];
}
