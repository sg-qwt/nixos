let
  ghexpr = v: "\${{ ${v} }}";
  hosts = (builtins.attrNames (builtins.readDir ../hosts));
  if-clause = ghexpr "github.event.inputs.host == 'all' || (matrix.host == github.event.inputs.host)";
  step = attr : ({ "if" = if-clause; } // attr);
in
{
  _gentarget = ".github/workflows/build.yaml";

  name = "Build";

  on = {
    workflow_dispatch = {
      inputs = {
        host = {
          description = "Host to build";
          required = true;
          default = "all";
          type = "choice";
          options = hosts ++ [ "all" ];
        };
      };
    };
  };

  jobs = {
    build-nixos-configuration = {
      strategy = {
        matrix = {
          host = hosts;
        };
      };

      runs-on = "ubuntu-latest";

      steps = [
        (step {
          name = "Checkout";
          uses = "actions/checkout@v3";
        })
        (step {
          name = "Make more space";
          run = ''
            echo "=== Before pruning ==="
            df -h
            sudo rm -rf /usr/share /usr/local /opt || true
            echo
            echo "=== After pruning ==="
            df -h
          '';
        })
        (step {
          name = "Install Nix";
          uses = "cachix/install-nix-action@v22";
          "with" = {
            github_access_token = ghexpr "secrets.GITHUB_TOKEN";
          };
        }) 
        (step {
          name = "Setup Attic";
          uses = "icewind1991/attic-action@v1.1";
          "with" = {
            name = "hello";
            instance = "https://attic.edgerunners.eu.org";
            authToken = ghexpr "secrets.ATTIC_HELLO_TOKEN";
          };
        })
        (step {
          name = "Build host";
          run = ''
            nix build .#nixosConfigurations.${ghexpr "matrix.host"}.config.system.build.toplevel
          '';
        })
      ];
    };
  };
}
