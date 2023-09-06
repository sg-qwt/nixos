s@{ config, pkgs, lib, self, ... }:
let
  inherit (config.myos.data) fqdn openai;
  chatgpt-secret = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "matrix-chatgpt-bot.service" ];
  };
in
lib.mkProfile s "matrix-chatgpt" {

  sops.templates."matrix-chatgpt-extra-env".content = ''
    OPENAI_API_KEY=${config.sops.placeholder."openai_key"}
    MATRIX_BOT_PASSWORD=${config.sops.placeholder."matrix-bot-password"}
    MATRIX_ACCESS_TOKEN=${config.sops.placeholder."matrix-bot-token"}
  '';
  sops.secrets."openai_key" = {
    sopsFile = self + "/secrets/tfout.json";
    restartUnits = [ "matrix-chatgpt-bot.service" ];
  };
  sops.secrets."matrix-bot-password" = chatgpt-secret;
  sops.secrets."matrix-bot-token" = chatgpt-secret;

  systemd.services."matrix-chatgpt-bot" = {
    script = ''
      ${pkgs.my.matrix-chatgpt-bot}/bin/matrix-chatgpt-bot
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

      OPENAI_AZURE = "true";
      CHATGPT_REVERSE_PROXY = "https://eastus.api.cognitive.microsoft.com/openai/deployments/${openai.deployment}/chat/completions?api-version=2023-05-15";
    };
    after = [ "dendrite.service" ];
    wantedBy = [ "multi-user.target" ];
  };


}
