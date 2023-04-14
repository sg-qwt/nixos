''
  deploy() {
    nixos-rebuild --target-host deploy@"$1" --flake $MYOS_FLAKE#"$1" --use-remote-sudo switch
  }

  deploy-remote() {
    nixos-rebuild --build-host deploy@"$1" --target-host deploy@"$1" --flake $MYOS_FLAKE#"$1" --use-remote-sudo switch
  }
''
