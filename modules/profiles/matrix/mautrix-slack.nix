s@{ config, pkgs, lib, self, ... }:
let
  name = "mautrix-slack";
  inherit (config.myos.data) fqdn ports;

  host = "127.0.0.1";

  bot-secret = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "${name}.service" "dendrite.service" ];
  };

  bot-cfg = {
    logging = {
      min_level = "info";
      writers = [
        { format = "pretty-colored"; type = "stdout"; }
      ];
    };

    homeserver = {
      address = "https://${fqdn.edg}";
      domain = "${fqdn.edg}";
    };

    appservice = {
      id = "slack";
      address = "http://${host}:${toString ports.mautrix-slack}";
      hostname = host;
      port = ports.mautrix-slack;

      as_token = config.sops.placeholder.mautrix-slack-as;
      hs_token = config.sops.placeholder.mautrix-slack-hs;

      database = {
        type = "postgres";
        uri = "postgres:///${name}?host=/run/postgresql";
      };

      bot = {
        username = "slackbot";
      };

      async_transactions = false;
      ephemeral_events = false;
    };

    bridge = {
      username_template = "slack_{{.}}";
      displayname_template = "{{.RealName}} (S)";
      bot_displayname_template = "{{.Name}} (bot)";
      channel_name_template = "#{{.Name}}";

      portal_message_buffer = 128;

      delivery_receipts = false;

      message_error_notices = true;
      message_status_events = false;

      backfill = {
        enable = false;
      };

      command_prefix = "!slack";

      encryption = {
        allow = false;
        default = false;
      };

      federate_rooms = true;

      permissions = {
        "@dhl:${fqdn.edg}" = "admin";
      };
    };

  };

  registration = {
    id = bot-cfg.appservice.id;
    url = bot-cfg.appservice.address;
    as_token = bot-cfg.appservice.as_token;
    hs_token = bot-cfg.appservice.hs_token;
    sender_localpart = name;
    rate_limited = false;
    namespaces = {
      users = [
        {
          regex = "^@slack_.*:edgerunners\.eu\.org$";
          exclusive = true;
        }
        {
          regex = "^@slackbot:edgerunners\.eu\.org$";
          exclusive = true;
        }
      ];
    };
  };
in
lib.mkProfile s name {

  sops.secrets.mautrix-slack-as = bot-secret;
  sops.secrets.mautrix-slack-hs = bot-secret;
  sops.templates.mautrix-slack-cfg.content = builtins.toJSON bot-cfg;
  sops.templates.mautrix-slack-registration.content = builtins.toJSON registration;

  services.postgresql = {
    ensureDatabases = [ name ];
    ensureUsers = [
      {
        name = name;
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services."${name}" = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "postgresql.service" ];
    after = [ "dendrite.service" "postgresql.service" ];

    serviceConfig = {
      Restart = "on-failure";
      DynamicUser = true;
      StateDirectory = name;
      LoadCredential = [
        "config:${config.sops.templates.mautrix-slack-cfg.path}"
      ];
      ExecStart = "${pkgs.my.mautrix-slack}/bin/mautrix-slack --no-update --config %d/config";
    };
  };


}
