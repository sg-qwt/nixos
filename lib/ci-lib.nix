rec {
  ors = exprs: builtins.concatStringsSep " || " exprs;
  ands = exprs: builtins.concatStringsSep " && " exprs;
  ghexpr = v: "\${{ ${v} }}";
  runs-on = "ubuntu-latest";
  hosts = (builtins.attrNames (builtins.readDir ../hosts));
  steps = {
    checkout = {
      name = "Checkout";
      uses = "actions/checkout@v4.2.2";
    };

    install-nix = {
      name = "Install Nix";
      uses = "cachix/install-nix-action@v30";
      "with" = {
        github_access_token = ghexpr "secrets.PAT";
      };
    };

    flake-check = {
      name = "Flake Check";
      run = "nix flake check --verbose --print-build-logs";
    };

    eval-host = h: {
      name = "Eval Host ${h}";
      run = "nix eval --raw .#nixosConfigurations.${h}.config.system.build.toplevel
";
    };

    make-space = {
      name = "Make More Space";
      run = ''
        echo "=== Before pruning ==="
        df -h
        sudo rm -rf /usr/share /usr/local /opt || true
        echo
        echo "=== After pruning ==="
        df -h
      '';
    };

    set-swap = {
      name = "Set Swap Space";
      uses = "pierotofy/set-swap-space@v1.0";
      "with" = {
        swap-size-gb = 10;
      };
    };

    setup-attic-cache = {
      name = "Setup Attic Cache";
      uses = "icewind1991/attic-action@v1.2.1";
      "with" = {
        name = "hello";
        instance = "https://attic.edgerunners.eu.org";
        authToken = ghexpr "secrets.ATTIC_HELLO_TOKEN";
      };
    };

    build-host = h: {
      name = "Build Host ${h}";
      run = ''
        nix run nixpkgs#nix-fast-build -- --skip-cached --no-nom --flake ".#nixosConfigurations.${h}.config.system.build.toplevel"
      '';
    };
  };
}
