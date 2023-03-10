s@{ config, pkgs, lib, helpers, rootPath, ... }:
helpers.mkProfile s "shell"
{
  environment = {
    systemPackages = with pkgs; [
      zoxide
    ];
  };

  home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {

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
        wake-up = "${pkgs.wol}/bin/wol 9c:5c:8e:bb:ce:7d";
        rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/nixos";
      };
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
    };

    xdg.configFile."starship.toml".source = (rootPath + "/config/starship/starship.toml");
  };
}
