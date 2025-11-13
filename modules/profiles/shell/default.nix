s@{ config, pkgs, lib, self, ... }:
let
  me = config.myos.user.mainUser;
  me-secret = {
    owner = config.users.users.${me}.name;
    group = config.users.users.${me}.group;
  };
in
lib.mkProfile s "shell"
{
  vaultix.secrets.atuin-key = me-secret;
  vaultix.secrets.atuin-session = me-secret;

  myhome = { config, osConfig, ... }: {
    home.sessionVariables = {
      MYOS_FLAKE = "$HOME/nixos";
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
      '';

      historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];

      shellAliases = {
        gpr = "git pull --rebase";
        gl = "git log --decorate --oneline --graph";
        rebuild = "nixos-rebuild switch --sudo --flake $MYOS_FLAKE";
        nfc = "nix flake check";
        nf = "nix fmt";
        ns = "nix shell";
        nd = "nix develop";
        pass = "head -c20 < /dev/random | base64";
        tm = "tmux new-session -A -s main";
        pb = "curl -F 'c=@-' 'https://fars.ee/'";
      };
    };

    programs.starship = {
      enable = true;
      package = pkgs.starship;
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

    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        key_path = osConfig.vaultix.secrets.atuin-key.path;
        session_path = osConfig.vaultix.secrets.atuin-session.path;
        update_check = false;
        auto_sync = true;
        sync_frequency = "1h";
        search_mode = "fuzzy";
        enter_accept = false;
        sync.records = true;
        dotfiles.enabled = true;
      };
    };

  };
}
