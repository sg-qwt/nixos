s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "shell"
{
  environment = {
    variables = {
      MYOS_FLAKE = "$HOME/nixos";
    };
  };

  home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      defaultCommand = "${pkgs.ripgrep}/bin/rg --files";
      defaultOptions = [ "--bind ctrl-l:accept" ];
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.bash = {
      enable = true;

      initExtra = ''
        source ${pkgs.complete-alias}/bin/complete_alias

        complete -F _complete_alias "''${!BASH_ALIASES[@]}"

        if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
	        source ${./emacs-vterm-bash.sh}
        fi
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

    xdg.configFile."starship.toml".source = ./starship.toml;
  };
}