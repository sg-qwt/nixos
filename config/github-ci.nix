let
  ghexpr = v: "\${{ ${v} }}";
  hosts = (builtins.attrNames (builtins.readDir ../hosts));
in
{
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
              trusted-public-keys = oranc:RZWCxVsNWs/6qPkfB17Mmk9HpkTv87UXnldHtGKkWLk= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= linyinfeng.cachix.org-1:sPYQXcNrnCf7Vr7T0YmjXz5dMZ7aOKG3EqLja0xr9MM=
              substituters = https://ooo.edgerunners.eu.org/ghcr.io/sg-qwt/nixos https://cache.nixos.org https://nix-community.cachix.org https://linyinfeng.cachix.org
            '';
          };
        }
        {
          name = "Build and push with oranc";
          env = {
            ORANC_USERNAME = "sg-qwt";
            ORANC_PASSWORD = ghexpr "secrets.ORANC_PASSWORD";
            ORANC_SIGNING_KEY = ghexpr "secrets.ORANC_SIGNING_KEY";
          };
          run = ''
            nix develop .#ci --command \
            bb build-cache ${ghexpr "matrix.host"}
          '';
        }
      ];
    };
  };
}
