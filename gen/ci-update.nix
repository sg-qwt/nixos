{ lib }:
let
  cilib = import ../lib/ci-lib.nix;
  inherit (cilib) ghexpr runs-on steps;
in
{
  _gentarget = ".github/workflows/update.yaml";

  name = "Update";

  on = {
    workflow_dispatch = { };
    schedule = [
      { cron = "0 0 1 * *"; }
    ];
  };

  jobs = {
    update-job = {
      inherit runs-on;

      steps = [
        steps.checkout
        steps.install-nix
        {
          name = "Update";
          id = "update";
          run = ''
            nix run .#ci-update
          '';
        }
        {
          name = "Create PR";
          uses = "peter-evans/create-pull-request@v5.0.2";
          "with" = {
            commit-message = "auto: flake update";
            title = "Update flake.lock sources";
            token = ghexpr "secrets.PAT";
            body = ghexpr "steps.update.outputs.report";
            branch = "ci-update";
            delete-branch = true;
          };
        }
      ];
    };
  };
}
