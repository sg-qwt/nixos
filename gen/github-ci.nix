let
  ghexpr = v: "\${{ ${v} }}";
  hosts = (builtins.attrNames (builtins.readDir ../hosts));
in
{
  _gentarget = ".github/workflows/build.yaml";

  name = "Build";
  on = {
    workflow_dispatch = { };
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
        {
          name = "Checkout";
          uses = "actions/checkout@v3";
        }
        {
          name = "Make more space";
          run = ''
            echo "=== Before pruning ==="
            df -h
            sudo rm -rf /usr/share /usr/local /opt || true
            echo
            echo "=== After pruning ==="
            df -h
          '';
        }
        {
          name = "Install Nix";
          uses = "cachix/install-nix-action@v19";
          "with" = {
            github_access_token = ghexpr "secrets.GITHUB_TOKEN";
            extra_nix_config = ''
              extra-substituters = https://staging.attic.rs/attic-ci
              extra-trusted-public-keys = attic-ci:U5Sey4mUxwBXM3iFapmP0/ogODXywKLRNgRPQpEXxbo=
            '';
          };
        }
        {
          name = "Build and push with Attic";
          run = ''
            nix develop .#ci --command \
            bb build-cache ${ghexpr "matrix.host"}
          '';
          env = {
            ATTIC_SERVER = "https://attic.edgerunners.eu.org/";
            ATTIC_CACHE = "hello";
            ATTIC_TOKEN = ghexpr "secrets.ATTIC_HELLO_TOKEN";
          };
        }
      ];
    };
  };
}
