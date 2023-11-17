s@{ config, pkgs, lib, self, ... }:
let
  sops-file = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "dygift.service" ];
  };
in
lib.mkProfile s "dygift" {
  sops.secrets.dygift-did = sops-file;
  sops.secrets.dygift-ltp0 = sops-file;

  sops.templates.dygift-config.content = lib.generators.toYAML { } {
    cron = {
      refresh = "0 10 0 * * *";
      renewal = "0 50 23 * * *";
    };
    douyu = {
      did = config.sops.placeholder.dygift-did;
      ltp0 = config.sops.placeholder.dygift-ltp0;
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
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [
      config.sops.templates.dygift-config.content
    ];
    serviceConfig = {
      DynamicUser = true;
      LoadCredential = [
        "config:${config.sops.templates.dygift-config.path}"
      ];
      ExecStart = "${pkgs.my.douyu-task}/bin/douyu-task cron --config %d/config";
      Restart = "on-failure";
    };
  };
}
