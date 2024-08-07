s@{ config, pkgs, lib, self, ... }:
with lib;
let
  cfg = config.myos.matrix;
  inherit (config.myos.data) fqdn ports;
  workingDir = "/var/lib/dendrite";
  httpPort = ports.dendrite;
  settingsFormat = pkgs.formats.yaml { };
  configurationYaml = settingsFormat.generate "dendrite.yaml"
    (import ./dendrite-cfg.nix { inherit config workingDir lib; });
  clientConfig =
    {
      "m.homeserver".base_url = "https://${fqdn.edg}";
      "m.identity_server".base_url = "https://vector.im";
    } //
    (optionalAttrs cfg.sliding-sync {
      "org.matrix.msc3575.proxy".url = "https://matrix-sliging-sync.${fqdn.edg}";
    });

  serverConfig."m.server" = "${fqdn.edg}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  imports = [
    ./matrix-chatgpt.nix
    ./mautrix-slack.nix
    ./sliding-sync.nix
  ];

  options.myos.matrix = {
    enable = mkEnableOption "matrix";
    chatgpt-bot = mkEnableOption "chatgpt bot";
    slack-bot = mkEnableOption "slack bot";
    sliding-sync = mkEnableOption "sliding sync";
  };

  config = mkIf cfg.enable {
    myos.matrix-chatgpt.enable = cfg.chatgpt-bot;
    myos.mautrix-slack.enable = cfg.slack-bot;
    myos.matrix-sliging-sync.enable = cfg.sliding-sync;

    services.postgresql = {
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
          ensureDBOwnership = true;
        }
      ];
    };

    sops.secrets.dendrite-sign-key = {
      sopsFile = self + "/secrets/secrets.yaml";
      restartUnits = [ "dendrite.service" ];
    };

    sops.secrets.dendrite-register = {
      sopsFile = self + "/secrets/secrets.yaml";
      restartUnits = [ "dendrite.service" ];
    };

    # max_file_size_bytes = 10485760;
    # client_max_body_size 
    systemd.services.dendrite = {
      description = "Dendrite Matrix homeserver";
      requires = [ "postgresql.service" ];
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
        ] ++ (lib.optional cfg.slack-bot "mautrix-slack-registration:${config.sops.templates.mautrix-slack-registration.path}");
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

  };
}
