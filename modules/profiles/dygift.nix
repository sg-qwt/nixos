s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "dygift" {
  vaultix.secrets.dygift-did = { };
  vaultix.secrets.dygift-ltp0 = { };

  vaultix.templates.dygift-config.content = lib.generators.toYAML { } {
    cron = {
      refresh = "0 10 0 * * *";
      renewal = "0 50 23 * * *";
    };
    douyu = {
      did = config.vaultix.placeholder.dygift-did;
      ltp0 = config.vaultix.placeholder.dygift-ltp0;
      room = 9999;
      ignore_expired_check = true;
      assigns = [
        {
          room = 500269;
          all = true;
        }
      ];
    };
  };

  systemd.services.dygift = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [
      config.vaultix.templates.dygift-config.content
    ];
    serviceConfig = {
      DynamicUser = true;
      LoadCredential = [
        "config:${config.vaultix.templates.dygift-config.path}"
      ];
      ExecStart = "${pkgs.my.douyu-task}/bin/douyu-task cron --config %d/config";
      Restart = "on-failure";
    };
  };
}
