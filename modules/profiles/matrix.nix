s@{ config, pkgs, lib, helpers, rootPath, ... }:
helpers.mkProfile s "matrix" (
  let
    inherit (config.myos.data) fqdn ports;
    workingDir = "/var/lib/dendrite";
    httpPort = ports.dendrite;
    settingsFormat = pkgs.formats.yaml { };
    configurationYaml = settingsFormat.generate "dendrite.yaml"
      (import (rootPath + "/config/matrix/dendrite.nix")
        { inherit config workingDir; });
    clientConfig."m.homeserver".base_url = "https://${fqdn.edg}";
    serverConfig."m.server" = "${fqdn.edg}:443";
    mkWellKnown = data: ''
      add_header Content-Type application/json;
      add_header Access-Control-Allow-Origin *;
      return 200 '${builtins.toJSON data}';
    '';
  in
  {
    services.postgresql = {
      enable = true;
      authentication = lib.mkForce ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';
      initdbArgs = [
        "--encoding=UTF8"
      ];
      ensureDatabases = [ "dendrite" ];
      ensureUsers = [
        {
          name = "dendrite";
          ensurePermissions."DATABASE dendrite" = "ALL PRIVILEGES";
        }
      ];
    };

    sops.secrets.dendrite-sign-key = {
      sopsFile = rootPath + "/secrets/secrets.yaml";
      restartUnits = [ "dendrite.service" ];
    };

    sops.secrets.dendrite-register = {
      sopsFile = rootPath + "/secrets/secrets.yaml";
      restartUnits = [ "dendrite.service" ];
    };

    # max_file_size_bytes = 10485760;
    # client_max_body_size 
    systemd.services.dendrite = {
      description = "Dendrite Matrix homeserver";
      after = [
        "network.target"
        "postgresql.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "dendrite";
        WorkingDirectory = workingDir;
        RuntimeDirectory = "dendrite";
        RuntimeDirectoryMode = "0700";
        LimitNOFILE = 65535;
        EnvironmentFile = config.sops.secrets.dendrite-register.path;
        LoadCredential = [
          "dendrite-sign-key:${config.sops.secrets.dendrite-sign-key.path}"
        ];
        ExecStartPre = [
          ''
            ${pkgs.envsubst}/bin/envsubst \
              -i ${configurationYaml} \
              -o /run/dendrite/dendrite.yaml
          ''
        ];
        ExecStart = lib.strings.concatStringsSep " " [
          "${pkgs.dendrite}/bin/dendrite"
          "--config /run/dendrite/dendrite.yaml"
          "--http-bind-address :${builtins.toString httpPort}"
        ];
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
      };
    };

    services.nginx.virtualHosts."${fqdn.edg}".locations = {
      "= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
      "= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
      "/_matrix" = {
        proxyPass = "http://[::1]:${toString httpPort}";
      };
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "new-matrix-user" ''
        set -e
        username="$1"
        if [[ -z "$username" ]]; then
          echo "usage: new-matrix-user <username>" >&2
          exit 1
        fi
        password="$(${pkgs.pwgen}/bin/pwgen -s 32 1)"
        ${pkgs.dendrite}/bin/create-account \
          --config /run/dendrite/dendrite.yaml \
          --url http://localhost:${builtins.toString httpPort} \
          --username "$username" \
          --passwordstdin <<<"$password"
        printf 'password: %s' "$password"
      '')
    ];

    systemd.services."matrix-chatgpt-bot" = {
      script = ''
        ${config.nur.repos.linyinfeng.matrix-chatgpt-bot}/bin/matrix-chatgpt-bot
      '';
      serviceConfig = {
        Restart = "on-failure";
        DynamicUser = true;
        StateDirectory = "matrix-chatgpt-bot";
        EnvironmentFile = [
          config.sops.templates."matrix-chatgpt-extra-env".path
        ];
      };
      environment = {
        DATA_PATH = "/var/lib/matrix-chatgpt-bot";

        CHATGPT_CONTEXT = "thread";
        CHATGPT_API_MODEL = "gpt-3.5-turbo";

        KEYV_BACKEND = "file";
        KEYV_URL = "";
        KEYV_BOT_ENCRYPTION = "false";
        KEYV_BOT_STORAGE = "true";

        MATRIX_HOMESERVER_URL = "https://${fqdn.edg}";
        MATRIX_BOT_USERNAME = "@chatgptbot:${fqdn.edg}";

        MATRIX_DEFAULT_PREFIX = "!chatgpt";
        MATRIX_DEFAULT_PREFIX_REPLY = "false";

        MATRIX_WHITELIST = ":${fqdn.edg}";
        MATRIX_AUTOJOIN = "true";
        MATRIX_ENCRYPTION = "false";
        MATRIX_THREADS = "true";
        MATRIX_PREFIX_DM = "false";
        MATRIX_RICH_TEXT = "true";
      };
      after = [ "dendrite.service" ];
      wantedBy = [ "multi-user.target" ];
    };

    sops.templates."matrix-chatgpt-extra-env".content = ''
      OPENAI_API_KEY=${config.sops.placeholder."openai-api-key"}
      MATRIX_BOT_PASSWORD=${config.sops.placeholder."matrix-bot-password"}
      MATRIX_ACCESS_TOKEN=${config.sops.placeholder."matrix-bot-token"}
    '';
    sops.secrets."openai-api-key" = {
      sopsFile = rootPath + "/secrets/secrets.yaml";
      restartUnits = [ "matrix-chatgpt-bot.service" ];
    };
    sops.secrets."matrix-bot-password" = {
      sopsFile = rootPath + "/secrets/secrets.yaml";
      restartUnits = [ "matrix-chatgpt-bot.service" ];
    };
    sops.secrets."matrix-bot-token" = {
      sopsFile = rootPath + "/secrets/secrets.yaml";
      restartUnits = [ "matrix-chatgpt-bot.service" ];
    };

  }
)
