s@{ pkgs-latest, pkgs, lib, ... }:
lib.mkProfile s "shell"
{
  myhome = { config, ... }: {
    home.sessionVariables = {
      MYOS_FLAKE = "$HOME/nixos";
    };

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
      package = pkgs-latest.starship;
      enableBashIntegration = true;
      settings = lib.mkMerge [
        {
          add_newline = true;
          battery = {
            disabled = true;
          };
          directory = {
            home_symbol = "home";
          };
          nix_shell = {
            heuristic = true;
          };
        }
        (lib.importTOML "${config.programs.starship.package}/share/starship/presets/plain-text-symbols.toml")
      ];
    };
  };
}
