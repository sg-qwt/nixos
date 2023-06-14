s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "shell"
{
  environment = {
    variables = {
      MYOS_FLAKE = "$HOME/nixos";
    };
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

      shellAliases = {
        gpr = "git pull --rebase";
        gl = "git log --decorate --oneline --graph";
        # wg-up = "sudo systemctl start wg-quick-wg0.service";
        # wg-down = "sudo systemctl stop wg-quick-wg0.service";
        rebuild = "sudo nixos-rebuild switch --flake $MYOS_FLAKE";
        nfc = "nix flake check";
        nf = "nix fmt";
        ns = "nix shell";
        nd = "nix develop";
        pass = "head -c20 < /dev/random | base64";
      };
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
    };

    xdg.configFile."starship.toml".source = (self + "/config/starship/starship.toml");
  };
}
