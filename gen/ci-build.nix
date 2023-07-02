{ lib }:
let
  ghexpr = v: "\${{ ${v} }}";
  hosts = (builtins.attrNames (builtins.readDir ../hosts));
  if-clause = ghexpr
    "github.event.inputs.host == 'all' || (matrix.host == github.event.inputs.host) || (github.event.pull_request.head.repo.full_name == github.repository)";
  step = attr: ({ "if" = if-clause; } // attr);
  runs-on = "ubuntu-latest";
  common-steps = {
    checkout = {
      name = "Checkout";
      uses = "actions/checkout@v3";
    };
    install-nix = {
      name = "Install Nix";
      uses = "cachix/install-nix-action@v22";
      "with" = {
        github_access_token = ghexpr "secrets.GITHUB_TOKEN";
      };
    };
  };
  job-id = {
    check = "check-flake-and-formatter";
    eval-host = "check-eval-host";
  };
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
    push = { };
    pull_request = { };
  };

  jobs = {
    "${job-id.check}" = {
      inherit runs-on;

      steps = [
        common-steps.checkout
        common-steps.install-nix
        {
          name = "Check";
          run = "nix flake check --verbose --print-build-logs";
        }
      ];
    };

    "${job-id.eval-host}" = {
      inherit runs-on;
      needs = job-id.check;

      strategy = {
        fail-fast = false;
        matrix = {
          host = hosts;
        };
      };

      steps = [
        common-steps.checkout
        common-steps.install-nix
        {
          name = "Eval";
          run = "nix eval --raw .#nixosConfigurations.${ghexpr "matrix.host"}.config.system.build.toplevel
";
        }
      ];
    };

    build-nixos-configuration = {
      inherit runs-on;
      needs = [ job-id.check job-id.eval-host ];
      "if" = ghexpr "github.event_name == 'pull_request' || github.event_name == 'workflow_dispatch'";

      strategy = {
        matrix = {
          host = hosts;
        };
      };

      steps = [
        (step common-steps.checkout)
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
        (step common-steps.install-nix)
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
