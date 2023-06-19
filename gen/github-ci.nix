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

      "if" = if-clause;

      steps = [
        (step {
          name = "Checkout";
          uses = "actions/checkout@v3";})
        (step {
          name = "Make more space";
          run = ''
            echo "=== Before pruning ==="
            df -h
            sudo rm -rf /usr/share /usr/local /opt || true
            echo
            echo "=== After pruning ==="
            df -h
          '';})
        (step {
          name = "Install Nix";
          uses = "cachix/install-nix-action@v19";
          "with" = {
            github_access_token = ghexpr "secrets.GITHUB_TOKEN";
            extra_nix_config = ''
              extra-substituters = https://staging.attic.rs/attic-ci
              extra-trusted-public-keys = attic-ci:U5Sey4mUxwBXM3iFapmP0/ogODXywKLRNgRPQpEXxbo=
            '';
          };}) 
        (step {
          name = "Build and push with Attic";
          run = ''
            nix develop .#ci --command \
            bb build-cache ${ghexpr "matrix.host"}
          '';
          env = {
            ATTIC_SERVER = "https://attic.edgerunners.eu.org/";
            ATTIC_CACHE = "hello";
            ATTIC_TOKEN = ghexpr "secrets.ATTIC_HELLO_TOKEN";
          };})
      ];
    };
  };
}
