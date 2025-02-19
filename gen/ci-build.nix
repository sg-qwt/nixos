{ lib, self }:
let
  cilib = import ../lib/ci-lib.nix;
  hosts = (builtins.attrNames self.nixosConfigurations);
  inherit (cilib) ghexpr ors runs-on steps;
  if-clause =
    ghexpr
      (ors [
        "(github.event.inputs.host == 'all')"
        "(matrix.host == github.event.inputs.host)"
        "(github.event.pull_request.head.repo.full_name == github.repository)"
        "(github.event_name == 'push')"
      ]);
  cond-step = step: ({ "if" = if-clause; } // step);
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
    push = {
      branches = [ "main" ];
    };
    pull_request = { };
  };

  jobs = {
    "${job-id.check}" = {
      inherit runs-on;

      steps = [
        steps.checkout
        steps.install-nix
        steps.flake-check
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
        steps.checkout
        steps.install-nix
        (steps.eval-host (ghexpr "matrix.host"))
      ];
    };

    build-nixos-configuration = {
      inherit runs-on;
      needs = [ job-id.check job-id.eval-host ];

      # "if" =
      #   ghexpr
      #     (ors [
      #       "(github.event_name == 'pull_request')"
      #       "(github.event_name == 'workflow_dispatch')"
      #     ]);

      strategy = {
        fail-fast = false;
        matrix = {
          host = hosts;
        };
      };

      steps =
        (map cond-step
          [
            steps.make-space
            steps.set-swap
            steps.checkout
            steps.install-nix
            steps.setup-attic-cache
            (steps.build-host (ghexpr "matrix.host"))
          ]
        );
    };
  };
}
