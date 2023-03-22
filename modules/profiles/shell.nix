s@{ config, pkgs, lib, helpers, rootPath, ... }:
helpers.mkProfile s "shell"
{
  environment = {
    systemPackages = with pkgs; [
      zoxide
    ];
  };

  home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
    home.sessionVariables.MYOS_FLAKE = "${config.home.homeDirectory}/nixos";

    programs.bash = {
      enable = true;

      initExtra = ''
        eval "$(${pkgs.zoxide}/bin/zoxide init bash)"
      '';

      historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];

      bashrcExtra = (import (rootPath + "/config/scripts/bashrc.nix"));

      shellAliases = {
        gpr = "git pull --rebase";
        gl = "git log --decorate --oneline --graph";
        wg-up = "sudo systemctl start wg-quick-wg0.service";
        wg-down = "sudo systemctl stop wg-quick-wg0.service";
        rebuild = "sudo nixos-rebuild switch --flake $MYOS_FLAKE";
        pass = "head -c20 < /dev/random | base64";
      };
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
    };

    xdg.configFile."starship.toml".source = (rootPath + "/config/starship/starship.toml");
  };
}
