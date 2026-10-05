s@{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  pi = pkgs.my.pi;
  adrive-key = config.vaultix.secrets.az-drive-account-key.path;
in
lib.mkProfile s "aitooling" {
  vaultix.secrets.az-drive-account-key = {
    owner = config.myos.user.mainUser;
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
  };

  myhome = { config, osConfig, ... }: {
    programs.pi-coding-agent = {
      enable = true;
      appendSystem = ./APPEND_SYSTEM.md;
      package = pi;
      settings = {
        lastChangelogVersion = pi.version;
        defaultProvider = "openai-codex";
        defaultModel = "gpt-6.1-sol";
        defaultThinkingLevel = "high";
        transport = "auto";
        sessionDir = "${config.home.homeDirectory}/cloud/adrive/pi-sessions";
        defaultTools = [ "+codemode" ];
      };
    };

    # Wait for Vaultix to publish the secret before rendering rclone.conf.
    systemd.user.services.rclone-config = {
      Unit.ConditionPathExists = adrive-key;
      Service.RemainAfterExit = true;
      Install.WantedBy = lib.mkForce [ ];
    };

    systemd.user.paths.rclone-config = {
      Path.PathExists = adrive-key;
      Install.WantedBy = [ "default.target" ];
    };

    programs.rclone = {
      enable = true;
      remotes = {
        adrive = {
          config = {
            type = "azureblob";
            account = self.tfo.az-drive-account-name;
          };
          secrets = {
            key = adrive-key;
          };
          mounts = {
            "${self.tfo.az-drive-container-name}" = {
              enable = true;
              mountPoint = "${config.home.homeDirectory}/cloud/adrive";
              options = {
                vfs-cache-mode = "full";
                vfs-cache-max-age = "30d";
                vfs-cache-max-size = "10G";

                dir-cache-time = "15m";

                vfs-write-back = "30s";
              };
            };
          };

        };
      };
    };
  };
}
