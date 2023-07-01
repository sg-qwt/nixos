{ lib }:
let
  ghexpr = v: "\${{ ${v} }}";
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
        common-steps.checkout
        common-steps.install-nix
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
            commit-message = "auto: flake and nvfetcher update";
            title = "Update flake.lock and nvfetcher sources";
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
