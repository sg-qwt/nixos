s@{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  pi = pkgs.my.pi;
  piro = pkgs.writeScriptBin "piro" ''
    exec ${lib.getExe pi} --tools read,grep,find,ls "$@"
  '';
  adrive-key = config.vaultix.secrets.az-drive-account-key.path;
in
lib.mkProfile s "aitooling" {
  vaultix.secrets.az-drive-account-key = {
    owner = config.myos.user.mainUser;
  };

  environment.systemPackages = with pkgs; [
    pi
    piro
  ];

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
  };

  myhome = { config, osConfig, ... }: {
    home.file.".pi/agent/APPEND_SYSTEM.md" = {
      source = ./APPEND_SYSTEM.md;
      force = true;
    };

    home.file.".pi/agent/settings.json" = {
      text = builtins.toJSON {
        lastChangelogVersion = pi.version;
        defaultProvider = "openai-codex";
        defaultModel = "gpt-6-sol";
        defaultThinkingLevel = "high";
        transport = "auto";
        sessionDir = "${config.home.homeDirectory}/cloud/adrive/pi-sessions";
      };
      force = true;
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
            };
          };

        };
      };
    };
  };
}
