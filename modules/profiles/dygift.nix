s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "dygift" {
  vaultix.secrets.dygift-did = { };
  vaultix.secrets.dygift-ltp0 = { };

  vaultix.templates.dygift-config.content = lib.generators.toYAML { } {
    log = {
      console = {
        format = "text";
        level = "INFO";
      };
    };
    douyu = {
      cron = {
        disable = true;
        spec = "0 0 12 * * *";
        startup = false;
        jitter = 10;
      };
      accounts = [
        {
          phone = "main";
          did = config.vaultix.placeholder.dygift-did;
          ltp0 = config.vaultix.placeholder.dygift-ltp0;
          room = 9999;
          assigns = [
            {
              room = 500269;
              all = true;
            }
          ];
          ignore_expired_check = true;
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
      ExecStart = "${lib.getExe pkgs.my.sign-task} -c %d/config cron";
      Restart = "on-failure";
    };
  };
}
